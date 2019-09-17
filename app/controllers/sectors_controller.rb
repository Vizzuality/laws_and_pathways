class SectorsController < ApplicationController
  def index
    @companies_by_levels = companies_grouped_by_sector_levels(Company)

    @sectors_cp_data = sectors_scenarios_alignments

    @sectors_names = Sector.order(:name).pluck(:id, :name)
    @companies_names = Company.limit(20).pluck(:id, :name)
  end

  def show
    @sector = Sector.find(params[:id])

    @companies_by_levels = companies_grouped_by_sector_levels(@sector.companies)
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
  #  ['1', ['Air China', 'China Southern', 'Singapore Airlines']],
  #  ['3', ['Alaska Air', 'IAG', 'Japan Airlines']]
  # ]
  def companies_grouped_by_sector_levels(company_scope)
    ::Api::Sectors::CompaniesNamesGroupedByLevel.new(company_scope).get
  end
end
