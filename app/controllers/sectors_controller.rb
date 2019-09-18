class SectorsController < ApplicationController
  def index
    @sectors_names = Sector.order(:name).pluck(:id, :name)
    @companies_names = Company.limit(50).pluck(:id, :name)
  end

  def show
    @sector = Sector.find(params[:id])

    @companies_by_levels = ::Api::Sectors::CompaniesGroupedByLevel.new(companies_scope(params)).get
  end

  # Chart data endpoints

  # Returns array of pairs:
  #   [latest MQ assessment Sector's level, number of Companies on given level]
  #
  # If params[:id] is given results are scoped to given Sector.
  #
  # @example:
  #   [
  #     ['0', 13],
  #     ['1', 63],
  #     ['2', 61],
  #     ['3', 71],
  #     ['4', 63],
  #     ['4STAR', 6]
  #   ]
  #
  def companies_levels
    data = ::Api::Sectors::CompaniesGroupedByLevel.new(companies_scope(params)).count

    render json: data.chart_json
  end

  # Returns array of objects with props:
  # - name - Company name
  # - data - object representing emissions history ({ year: emission-value })
  #
  # If params[:id] is given results are scoped to given Sector.
  #
  # @example
  #   [
  #     { name: 'WizzAir', data: {} },
  #     { name: 'Air China', data: {'2014' => 111.0, '2015' => 112.0 } },
  #     { name: 'China Southern', data: {'2014' => 114.0, '2015' => 112.0 } }
  #   ]
  #
  def companies_emissions
    data = ::Api::Sectors::CompaniesGroupedByLevel.new(companies_scope(params)).emissions

    render json: data.chart_json
  end

  def scenarios
    render json: sectors_scenarios_alignments.chart_json
  end

  def sectors_scenarios_alignments
    ::Api::Sectors::CompaniesCountGroupedByScenario.new.get
  end

  def companies_scope(params)
    if params[:id]
      Sector.find(params[:id]).companies
    else
      Company
    end
  end
end
