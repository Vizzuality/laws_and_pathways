# == Schema Information
#
# Table name: cp_assessments
#
#  id                         :bigint           not null, primary key
#  company_id                 :bigint
#  publication_date           :date             not null
#  assessment_date            :date
#  emissions                  :jsonb
#  assumptions                :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  discarded_at               :datetime
#  last_reported_year         :integer
#  cp_alignment_2050          :string
#  cp_alignment_2025          :string
#  cp_alignment_2035          :string
#  years_with_targets         :integer          is an Array
#  region                     :string
#  cp_regional_alignment_2025 :string
#  cp_regional_alignment_2035 :string
#  cp_regional_alignment_2050 :string
#

module CP
  class Assessment < ApplicationRecord
    include HasEmissions
    include DiscardableModel
    include TPICache

    REGIONS = CP::Benchmark::REGIONS - ['Global']

    belongs_to :cp_assessmentable, polymorphic: true
    belongs_to :company, foreign_type: 'Company', foreign_key: 'cp_assessmentable_id', optional: true
    belongs_to :bank, foreign_type: 'Bank', foreign_key: 'cp_assessmentable_id', optional: true
    belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id', optional: true

    scope :latest_first, -> { order(assessment_date: :desc) }
    scope :all_publication_dates, -> { distinct.order(publication_date: :desc).pluck(:publication_date) }
    scope :published_on_or_before, lambda { |publication_date|
      order(:publication_date).where('publication_date <= ?', publication_date)
    }
    scope :currently_published, -> { where('publication_date <= ?', DateTime.now) }
    scope :regional, -> { where.not(region: [nil, '']) }
    scope :companies, -> { where(cp_assessmentable_type: 'Company') }
    scope :banks, -> { where(cp_assessmentable_type: 'Bank') }

    validates_presence_of :publication_date
    validates_presence_of :last_reported_year, if: -> { emissions&.keys&.any? }
    validates :assessment_date, date_after: Date.new(2010, 12, 31)
    validates :publication_date, date_after: Date.new(2010, 12, 31)
    validates :region, inclusion: {in: REGIONS}, allow_nil: true

    with_options allow_nil: true, allow_blank: true, inclusion: {in: CP::Alignment::ALLOWED_NAMES} do
      validates :cp_alignment_2025
      validates :cp_alignment_2027
      validates :cp_alignment_2035
      validates :cp_alignment_2050
      validates :cp_regional_alignment_2025
      validates :cp_regional_alignment_2027
      validates :cp_regional_alignment_2035
      validates :cp_regional_alignment_2050
    end

    def unit
      cp_assessmentable.sector.cp_unit_valid_for_date(publication_date)&.unit
    end

    def cp_benchmark_id
      benchmarks&.first&.benchmark_id
    end

    def cp_regional_benchmark_id
      regional_benchmarks&.first&.benchmark_id if region.present?
    end

    def years_with_targets_string=(value)
      self.years_with_targets = value.split(',').map(&:strip).map(&:to_i).reject(&:zero?)
    end

    def years_with_targets_string
      years_with_targets&.join(', ')
    end

    private

    def benchmarks
      cp_assessmentable.sector.latest_benchmarks_for_date(publication_date, category: cp_assessmentable_type)
    end

    def regional_benchmarks
      cp_assessmentable.sector.latest_benchmarks_for_date(publication_date, category: cp_assessmentable_type, region: region)
    end
  end
end
