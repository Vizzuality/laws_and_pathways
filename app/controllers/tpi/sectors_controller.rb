module TPI
  class SectorsController < TPIController
    include UserDownload

    before_action :enable_beta_mq_assessments
    before_action :fetch_companies, only: [:show, :index]
    before_action :fetch_sectors, only: [:show, :index, :user_download_all]
    before_action :fetch_sector, only: [:show, :user_download]
    before_action :redirect_if_numeric_or_historic_slug, only: [:show]

    helper_method :any_cp_assessment?

    def index
      @companies_by_sectors = Rails.cache.fetch(
        "#{TPICache::KEY}-mq-beta-scores-#{session[:enable_beta_mq_assessments]}",
        expires_in: TPICache::EXPIRES_IN
      ) do
        ::Api::Charts::Sector.new(
          companies_scope(params), enable_beta_mq_assessments: session[:enable_beta_mq_assessments]
        ).companies_market_cap_by_sector
      end
      @publications_and_articles = publications_and_articles
      sectors_page = TPIPage.find_by(slug: 'publicly-listed-equities-content')
      @methodology_description = Content.find_by(page: sectors_page, code: 'methodology_description')
      @methodology_id = Content.find_by(page: sectors_page, code: 'methodology_publication_id')
      @beta_methodology_id = Content.find_by(page: sectors_page, code: 'beta_methodology_publication_id')
      @methodology_id = @beta_methodology_id || @methodology_id if session[:enable_beta_mq_assessments]
      @methodology_publication = Publication.find_by(id: @methodology_id&.text)

      fixed_navbar('Sectors', admin_tpi_sectors_path)
    end

    def show
      @sector_companies = @companies.active.select { |c| c.sector_id == @sector.id }

      @companies_by_levels = ::Api::Charts::Sector.new(
        companies_scope(params), enable_beta_mq_assessments: session[:enable_beta_mq_assessments]
      ).companies_summaries_by_level

      @publications_and_articles = @sector.publications_and_articles

      fixed_navbar("Sector #{@sector.name}", admin_tpi_sector_path(@sector))
    end

    # Chart data endpoints

    # Data:     Sectors Companies number, grouped by Levels
    # Section:  MQ
    # Type:     pie chart
    # On pages: :index, :show
    def levels_chart_data
      data = ::Api::Charts::Sector.new(
        companies_scope(params), enable_beta_mq_assessments: session[:enable_beta_mq_assessments]
      ).companies_count_by_level

      render json: data.chart_json
    end

    # Data:     Companies emissions
    # Section:  CP
    # Type:     line chart
    # On pages: :show
    def emissions_chart_data
      data = ::Api::Charts::Sector.new(
        companies_scope(params), enable_beta_mq_assessments: session[:enable_beta_mq_assessments]
      ).companies_emissions_data

      render json: data.chart_json
    end

    # Data:     Sector Companies numbers, grouped by CP Alignement from given Sector
    # Section:  CP
    # Type:     column chart
    # On pages: :index
    def cp_performance_chart_data
      data = ::Api::Charts::CPPerformance.new.cp_performance_all_sectors_data

      render json: data.chart_json
    end

    def send_download_file_info_email
      DataDownloadMailer.send_download_file_info_email(permitted_email_params).deliver_now
      head :ok
    end

    def user_download_all
      send_user_download_file(
        Company.published.select(:id).where(sector_id: @sectors.pluck(:id)),
        'TPI sector data - All sectors'
      )
    end

    def user_download
      send_user_download_file(
        @sector.companies.published.select(:id),
        "TPI sector data - #{@sector.name}"
      )
    end

    def user_download_methodology
      file_path = Rails.root.join('public', 'static_files', 'TPI’s methodology report. Management Quality and Carbon Performance.pdf')
      send_file file_path, type: 'application/pdf', disposition: 'attachment'
    end

    private

    def any_cp_assessment?
      CP::Assessment.currently_published.companies.joins(company: :sector).where(companies: {sector: @sector}).any? &&
        CP::Benchmark.where(sector: @sector).exists?
    end

    def publications_and_articles
      Queries::TPI::NewsPublicationsQuery.new(
        sectors: TPISector.companies.tpi_tool.pluck(:name).join(','),
        tags: 'State of Transition,Carbon Performance,Publicly listed companies,Public consultations'
      ).call.take(3)
    end

    def send_user_download_file(companies_ids, filename)
      mq_assessments = MQ::Assessment
        .currently_published
        .where(company_id: companies_ids)
        .joins(:company)
        .order('companies.name ASC, assessment_date DESC')
        .includes(company: [:sector, :geography, :mq_assessments])
      cp_assessments = CP::Assessment
        .currently_published
        .companies
        .where(cp_assessmentable_id: companies_ids)
        .joins(:company)
        .order('companies.name ASC, assessment_date DESC')
        .includes(company: [:geography, sector: [:cp_units]])

      send_tpi_user_file(
        mq_assessments: mq_assessments,
        cp_assessments: cp_assessments,
        filename: filename
      )
    end

    def fetch_sector
      @sector = TPISector.companies.tpi_tool.friendly.find(params[:id])
    end

    def redirect_if_numeric_or_historic_slug
      redirect_to tpi_sector_path(@sector.slug), status: :moved_permanently if params[:id] != @sector.slug
    end

    def fetch_sectors
      @sectors = TPISector.tpi_tool.with_companies.includes(:cluster).order(:name)
      @sectors_json = @sectors.map { |s| s.as_json(except: [:created_at, :updated_at], methods: [:path]) }
    end

    def fetch_companies
      @companies = Company
        .published
        .joins(:sector)
        .select(:id, :name, :slug, :sector_id, 'tpi_sectors.name as sector_name', :active)
        .order('tpi_sectors.name', :name)
    end

    def companies_scope(params)
      if params[:id]
        TPISector.tpi_tool.friendly.find(params[:id]).companies.published.active
      else
        Company.published.active
      end
    end

    def permitted_email_params
      params.permit(:email, :job_title, :forename, :surname, :location, :organisation, :other_purpose, purposes: [])
    end
  end
end
