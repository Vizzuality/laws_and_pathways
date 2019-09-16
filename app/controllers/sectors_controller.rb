class SectorsController < ApplicationController
  CP_ALIGNMENTS = %w[below_2 exact_2 paris not_aligned no_disclosure].freeze

  def index
    @companies_by_levels = get_companies_grouped_by_sector_levels(Company)

    @sectors_names = Sector.pluck(:id, :name).sort_by { |_id, name| name }
    @sectors_cp_data = CP_ALIGNMENTS.map do |cp_alignment| # CP alignments are series
      {
        name: get_alignment_label(cp_alignment),
        data: get_companies_count_for_cp_alignment(cp_alignment)
      }
    end
  end

  def show
    @sector = Sector.find(params[:id])

    @companies_by_levels = get_companies_grouped_by_sector_levels(@sector.companies)
  end

  # get companies grouped by their latest MQ assessments sector's levels
  def get_companies_grouped_by_sector_levels(company_scope)
    company_scope
      .includes(:mq_assessments)
      .group_by { |company| company.mq_assessments.order(:assessment_date).first.level }
  end

  def get_alignment_label(cp_alignment)
    {
      below_2: 'Below 2',
      exact_2: '2 degrees',
      paris: 'Paris',
      not_aligned: 'Not aligned',
      no_disclosure: 'No disclosure'
    }[cp_alignment.to_sym]
  end

  def get_companies_count_for_cp_alignment(_cp_alignment)
    Sector.take(10).pluck(:id, :name).map do |_sector_id, sector_name|
      [sector_name, rand(100)]
    end
  end
end
