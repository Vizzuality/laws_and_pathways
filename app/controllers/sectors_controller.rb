class SectorsController < ApplicationController
  CP_SCENARIOS = %w[below_2 exact_2 paris not_aligned no_disclosure].freeze

  def index
    @companies_by_levels = companies_grouped_by_sector_levels(Company)

    @sectors_cp_data = sectors_scenarios_alignments

    @sectors_names = Sector.pluck(:id, :name).sort_by { |_id, name| name }
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
    CP_SCENARIOS.map do |cp_alignment|
      {
        name: get_alignment_label(cp_alignment),
        data: companies_count_per_sector_cp_scenarios(cp_alignment)
      }
    end
  end

  # Returns companies grouped by their latest MQ assessments sector's levels
  #
  # [
  #  ['1', ['Air China', 'China Southern', 'Korean Air', 'Singapore Airlines']],
  #  ['3', ['Alaska Air', 'IAG', 'Japan Airlines', 'Jetblue', 'LATAM', 'Qantas']]
  # ]
  def companies_grouped_by_sector_levels(company_scope)
    company_scope
      .includes(:mq_assessments)
      .group_by { |company| company.mq_assessments.order(:assessment_date).first.level }
      .sort_by { |level, _companies| level }
      .map { |level, companies| [level, companies_emissions(companies)] }
  end

  private

  def get_alignment_label(cp_alignment)
    {
      below_2: 'Below 2',
      exact_2: '2 degrees',
      paris: 'Paris',
      not_aligned: 'Not aligned',
      no_disclosure: 'No disclosure'
    }[cp_alignment.to_sym]
  end

  def companies_count_per_sector_cp_scenarios(_cp_alignment)
    Sector.pluck(:id, :name).map do |_sector_id, sector_name|
      [sector_name, rand(100)]
    end
  end

  def companies_emissions(companies)
    companies.map do |company|
      {
        name: company.name,
        emissions: company.cp_assessments.last&.emissions
      }
    end
  end
end
