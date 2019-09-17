class SectorsController < ApplicationController
  def index
    @sectors_names = Sector.order(:name).pluck(:id, :name)
    @companies_names = Company.limit(20).pluck(:id, :name)
  end

  def show
    @sector = Sector.find(params[:id])

    @companies_by_levels = companies_grouped_by_sector_levels(companies_scope(params))
  end

  # chart data endpoints

  # Returns data:
  #   [
  #     ['0', 13],
  #     ['1', 63],
  #     ['2', 61],
  #     ['3', 71],
  #     ['4', 63],
  #     ['4STAR', 6]
  #   ]
  def companies_levels
    data = companies_grouped_by_sector_levels(companies_scope(params))
      .map { |level, companies| [level, companies.size] }

    render json: data.chart_json
  end

  # [
  #   { name: 'WizzAir', data: {} },
  #   { name: 'Air China', data: {'2014' => 111.0, '2015' => 112.0 } },
  #   { name: 'China Southern', data: {'2014' => 114.0, '2015' => 112.0 } }
  # ]
  def companies_emissions
    data = companies_grouped_by_sector_levels(companies_scope(params))
      .map { |_level, companies| companies }
      .flatten.map { |company| {name: company[:name], data: company[:emissions]} }

    render json: data.chart_json
  end

  def scenarios
    render json: sectors_scenarios_alignments.chart_json
  end

  # Returns info of how many companies from each sector are in given CP scenario group
  #
  # [
  #  {
  #   name: 'Below 2',
  #   data: [ ['Coal Mining', 52], ['Steel', 73] ]
  #  },
  #  {
  #    name: 'Paris',
  #    data: [ ['Coal Mining', 65], ['Steel', 26] ]
  #  }
  # ]
  def sectors_scenarios_alignments
    ::Api::Sectors::CompaniesCountGroupedByScenario.new.get
  end

  # Returns companies grouped by their latest MQ assessments sector's levels
  #
  # [
  #  ['1',
  #    [
  #      { name: 'Air China', emissions: { 2013: 153, 2014: 142 } },
  #      { name: 'China Southern', emissions: { 2015: 32, 2016: 43 } }
  #    ]
  #  ],
  #  ['3',
  #    [
  #      { name: 'Alaska Air', emissions: { } },
  #      { name: 'IAG', emissions: { } }
  #      { name: 'Japan Airlines', emissions: { } }
  #    ]
  #   ]
  # ]
  def companies_grouped_by_sector_levels(company_scope)
    ::Api::Sectors::CompaniesNamesGroupedByLevel.new(company_scope).get
  end

  def companies_scope(params)
    if params[:id]
      Sector.find(params[:id]).companies
    else
      Company
    end
  end
end
