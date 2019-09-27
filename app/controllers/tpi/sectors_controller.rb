module Tpi
  class SectorsController < ApplicationController
    def index
      @sectors_names = Sector.order(:name).pluck(:id, :name)
      @companies_names = Company.limit(50).pluck(:id, :name)
    end

    def show
      @sector = Sector.find(params[:id])

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
        Sector.find(params[:id]).companies
      else
        Company
      end
    end
  end
end
