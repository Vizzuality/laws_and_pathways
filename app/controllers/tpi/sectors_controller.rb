module TPI
  class SectorsController < TPIController
    include UserDownload

    before_action :fetch_companies, only: [:show, :index]
    before_action :fetch_sectors, only: [:show, :index, :user_download_all]
    before_action :fetch_sector, only: [:show, :user_download]

    def index
      @companies_by_sectors = ::Api::Charts::Sector.new(companies_scope(params)).companies_market_cap_by_sector
    end

    def show
      @sector_companies = @companies.select { |c| c.sector_id == @sector.id }

      @companies_by_levels = ::Api::Charts::Sector.new(companies_scope(params)).companies_summaries_by_level
    end

    # Chart data endpoints

    # Data:     Sectors Companies number, grouped by Levels
    # Section:  MQ
    # Type:     pie chart
    # On pages: :index, :show
    def levels_chart_data
      data = ::Api::Charts::Sector.new(companies_scope(params)).companies_count_by_level

      render json: data.chart_json
    end

    # Data:     Companies emissions
    # Section:  CP
    # Type:     line chart
    # On pages: :show
    def emissions_chart_data
      data = ::Api::Charts::Sector.new(companies_scope(params)).companies_emissions_data

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

    def user_download_all
      companies_ids = Company.published.select(:id).where(sector_id: @sectors.pluck(:id))
      mq_assessments = MQ::Assessment
        .where(company_id: companies_ids)
        .joins(:company)
        .order('companies.name ASC, assessment_date DESC')
        .includes(company: [:sector, :geography, :mq_assessments])
      cp_assessments = CP::Assessment
        .where(company_id: companies_ids)
        .joins(:company)
        .order('companies.name ASC, assessment_date DESC')
        .includes(company: [:sector, :geography])

      send_tpi_user_file(
        mq_assessments: mq_assessments,
        cp_assessments: cp_assessments,
        filename: 'TPI sector data - All sectors'
      )
    end

    def user_download
      companies_ids = @sector.companies.published.select(:id)
      mq_assessments = MQ::Assessment
        .where(company_id: companies_ids)
        .joins(:company)
        .order('companies.name ASC, assessment_date DESC')
        .includes(company: [:sector, :geography, :mq_assessments])
      cp_assessments = CP::Assessment
        .where(company_id: companies_ids)
        .joins(:company)
        .order('companies.name ASC, assessment_date DESC')
        .includes(company: [:sector, :geography])

      send_tpi_user_file(
        mq_assessments: mq_assessments,
        cp_assessments: cp_assessments,
        filename: "TPI sector data - #{@sector.name}"
      )
    end

    private

    def fetch_sector
      @sector = TPISector.friendly.find(params[:id])
    end

    def fetch_sectors
      @sectors = TPISector.select(:id, :name, :slug).order(:name)
    end

    def fetch_companies
      @companies = Company
        .published
        .joins(:sector)
        .select(:id, :name, :slug, :sector_id, 'tpi_sectors.name as sector_name')
    end

    def companies_scope(params)
      if params[:id]
        TPISector.friendly.find(params[:id]).companies
      else
        Company
      end
    end
  end
end
