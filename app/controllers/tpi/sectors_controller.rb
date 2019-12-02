module TPI
  class SectorsController < TPIController
    before_action :fetch_companies, only: [:show, :index]
    before_action :fetch_sectors, only: [:show, :index]

    def index
      @companies_by_sectors = ::Api::Charts::Sector.new(companies_scope(params)).companies_market_cap_by_sector
    end

    def show
      @sector = TPISector.friendly.find(params[:id])
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

    # Data:     Sector Companies numbers, grouped by CP Benchmarks from given Sector
    # Section:  CP
    # Type:     column chart
    # On pages: :index
    def benchmarks_chart_data
      data = ::Api::Charts::CPPerformance.new.cp_performance_all_sectors_data

      render json: data.chart_json
    end

    private

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
