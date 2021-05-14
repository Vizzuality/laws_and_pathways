# == Schema Information
#
# Table name: cp_assessments
#
#  id                 :bigint           not null, primary key
#  company_id         :bigint
#  publication_date   :date             not null
#  assessment_date    :date
#  emissions          :jsonb
#  assumptions        :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#  last_reported_year :integer
#  cp_alignment       :string
#

module CP
  class Assessment < ApplicationRecord
    include HasEmissions
    include DiscardableModel
    include TPICache

    belongs_to :company

    scope :latest_first, -> { order(assessment_date: :desc) }
    scope :all_publication_dates, -> { distinct.order(publication_date: :desc).pluck(:publication_date) }
    scope :published_on_or_before, lambda { |publication_date|
      order(:publication_date).where('publication_date <= ?', publication_date)
    }
    scope :currently_published, -> { where('publication_date <= ?', DateTime.now) }

    validates_presence_of :publication_date
    validates_presence_of :last_reported_year, if: -> { emissions&.keys&.any? }
    validates :assessment_date, date_after: Date.new(2010, 12, 31)
    validates :publication_date, date_after: Date.new(2010, 12, 31)

    def unit
      company.sector.cp_unit_valid_for_date(publication_date)&.unit
    end

    def cp_alignment_year
      return cp_alignment_year_override if cp_alignment_year_override.present?

      benchmark = cp_alignment_benchmark
      return unless benchmark.present?

      # check years where emissions are less or equal those in benchmark
      aligned_years = emissions.merge(benchmark.emissions) { |_year, e, be| e <= be }
      aligned_years.select { |_year, go_over| go_over == true }.keys.map(&:to_i).min
    end

    def cp_alignment_benchmark
      benchmarks.find { |b| b.for_alignment?(cp_alignment) }
    end

    private

    def benchmarks
      company.sector.latest_benchmarks_for_date(publication_date)
    end
  end
end
