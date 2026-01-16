module TPI
  class CompaniesController < TPIController
    include UserDownload

    before_action :enable_beta_mq_assessments
    before_action :fetch_company
    before_action :redirect_if_numeric_or_historic_slug, only: [:show]
    before_action :fetch_cp_assessment, only: [:show, :cp_assessment, :emissions_chart_data]
    before_action :fetch_mq_assessment, only: [:show, :mq_assessment, :assessments_levels_chart_data]

    def show
      @company_presenter = ::Api::Presenters::Company.new(@company, params[:view])

      @sectors = TPISector.companies.tpi_tool.select(:id, :name, :slug).order(:name)
      @companies = Company.published.joins(:sector)
        .select(:id, :name, :slug, 'tpi_sectors.name as sector_name', :active)
        .order('tpi_sectors.name', :name)
      @companies = TPI::CompanyDecorator.decorate_collection(@companies)

      @industries = Industry.joins(:tpi_sectors)
        .where(tpi_sectors: {id: TPISector.tpi_tool.with_companies.pluck(:id)})
        .distinct
        .order(:name)
      @industries_json = @industries.map do |i|
        {
          id: i.id,
          name: i.name,
          slug: i.slug,
          path: tpi_corporate_industry_path(i.slug)
        }
      end

      fixed_navbar(
        "Company #{@company.name}",
        admin_company_path(@company)
      )
    end

    def mq_assessment; end

    def cp_assessment; end

    # Data:     Company MQ Assessments Levels over the years
    # Section:  MQ
    # Type:     line chart
    # On pages: :show
    def assessments_levels_chart_data
      data = ::Api::Charts::MQAssessment.new(
        @mq_assessment,
        enable_beta_mq_assessments: @company.show_beta_mq_assessments
      ).assessments_levels_data

      render json: data.chart_json
    end

    # Data:     Company emissions
    # Section:  CP
    # Type:     line chart
    # On pages: :show
    def emissions_chart_data
      data = ::Api::Charts::CPAssessment.new(@cp_assessment, params[:view]).emissions_data

      render json: data.chart_json
    end

    def user_download
      send_tpi_user_file(
        mq_assessments: @company.mq_assessments.currently_published.order(publication_date: :desc, methodology_version: :desc, assessment_date: :desc),
        cp_assessments: @company.cp_assessments.currently_published.order(assessment_date: :desc),
        filename: "TPI company data - #{@company.name}"
      )
    end

    private

    def fetch_company
      @company = TPI::CompanyDecorator.decorate(Company.published.friendly.find(params[:id]))
      @company.show_beta_mq_assessments = session[:enable_beta_mq_assessments]
    end

    def redirect_if_numeric_or_historic_slug
      redirect_to tpi_company_path(@company.slug), status: :moved_permanently if params[:id] != @company.slug
    end

    def fetch_cp_assessment
      @cp_assessment = if params[:cp_assessment_id].present?
                         @company.cp_assessments.find(params[:cp_assessment_id])
                       elsif params[:view] == 'regional'
                         @company.latest_cp_assessment_regional
                       else
                         @company.latest_cp_assessment
                       end
    end

    def fetch_mq_assessment
      @mq_assessment = if params[:mq_assessment_id].present?
                         @company.mq_assessments.find(params[:mq_assessment_id])
                       else
                         @company.latest_mq_assessment
                       end
    end
  end
end
