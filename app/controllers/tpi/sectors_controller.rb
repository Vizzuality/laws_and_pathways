module TPI
  class SectorsController < TPIController
    def index
      @sectors = TPISector.select(:id, :name, :slug).order(:name)
      @companies = Company.select(:id, :name, :slug)
      @companies_by_levels  = ::Api::Charts::Sector.new(companies_scope(params)).companies_summaries_by_level
      @companies_by_sectors = ::Api::Charts::Sector.new(companies_scope(params)).companies_market_cap_by_sector
    end

    def show
      @sector = TPISector.friendly.find(params[:id])

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
      data = ::Api::Charts::CPBenchmark.new.cp_performance_data

      render json: data.chart_json
    end

    private

    def companies_scope(params)
      if params[:id]
        TPISector.friendly.find(params[:id]).companies
      else
        Company
      end
    end
  end
end
