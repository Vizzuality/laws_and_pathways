module TPI
  class SectorsController < TPIController
    include UserDownload

    before_action :fetch_companies, only: [:show, :index]
    before_action :fetch_sectors, only: [:show, :index, :user_download_all]
    before_action :fetch_sector, only: [:show, :user_download]
    before_action :redirect_if_numeric_or_historic_slug, only: [:show]

    def index
      @companies_by_sectors = Rails.cache.fetch(TPICache::KEY, expires_in: TPICache::EXPIRES_IN) do
        ::Api::Charts::Sector.new(companies_scope(params)).companies_market_cap_by_sector
      end

      fixed_navbar('Sectors', admin_tpi_sectors_path)
    end

    def show
      @sector_companies = @companies.active.select { |c| c.sector_id == @sector.id }

      @companies_by_levels = ::Api::Charts::Sector.new(companies_scope(params)).companies_summaries_by_level

      @publications_and_articles = @sector.publications_and_articles

      fixed_navbar("Sector #{@sector.name}", admin_tpi_sector_path(@sector))
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

    private

    def send_user_download_file(companies_ids, filename)
      mq_assessments = MQ::Assessment
        .currently_published
        .where(company_id: companies_ids)
        .joins(:company)
        .order('companies.name ASC, assessment_date DESC')
        .includes(company: [:sector, :geography, :mq_assessments])
      cp_assessments = CP::Assessment
        .currently_published
        .where(company_id: companies_ids)
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
      @sector = TPISector.friendly.find(params[:id])
    end

    def redirect_if_numeric_or_historic_slug
      redirect_to tpi_sector_path(@sector.slug), status: :moved_permanently if params[:id] != @sector.slug
    end

    def fetch_sectors
      @sectors = TPISector.all.includes(:cluster).order(:name)
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
        TPISector.friendly.find(params[:id]).companies.published.active
      else
        Company.published.active
      end
    end
  end
end
