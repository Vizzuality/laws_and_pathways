class SectorsController < ApplicationController
  def index
    @sectors_names = Sector.order(:name).pluck(:id, :name)
    @companies_names = Company.limit(50).pluck(:id, :name)
  end

  def show
    @sector = Sector.find(params[:id])

    @companies_by_levels = ::Api::Charts::Sector.new(companies_scope(params)).companies_summaries
  end

  # Chart data endpoints

  # Data:     Sectors Levels mapped to number of Companies
  # Section:  MQ
  # Type:     pie chart
  # On pages: :index, :show
  def companies_levels
    data = ::Api::Charts::Sector.new(companies_scope(params)).companies_count

    render json: data.chart_json
  end

  # Data:     Companies emissions
  # Section:  CP
  # Type:     line chart
  # On pages: :show
  def companies_emissions
    data = ::Api::Charts::Sector.new(companies_scope(params)).companies_emissions

    render json: data.chart_json
  end

  # Data:     Sectors Companies numbers, grouped by CP Benchmarks from given Sector
  # Section:  CP
  # Type:     column chart
  # On pages: :index
  def scenarios
    data = ::Api::Charts::Sector.new(companies_scope(params)).group_by_cp_benchmark

    render json: data.chart_json
  end

  def companies_scope(params)
    if params[:id]
      Sector.find(params[:id]).companies
    else
      Company
    end
  end
end
