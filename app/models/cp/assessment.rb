# == Schema Information
#
# Table name: cp_assessments
#
#  id                         :bigint           not null, primary key
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
#  cp_assessmentable_type     :string
#  cp_assessmentable_id       :bigint
#  company_subsector_id       :bigint
#  sector_id                  :bigint
#  final_disclosure_year      :integer
#  cp_alignment_2027          :string
#  cp_regional_alignment_2027 :string
#  cp_alignment_2028          :string
#  cp_regional_alignment_2028 :string
#

module CP
  class Assessment < ApplicationRecord
    include HasEmissions
    include DiscardableModel
    include TPICache

    REGIONS = CP::Benchmark::REGIONS

    belongs_to :cp_assessmentable, polymorphic: true
    belongs_to :company, -> { joins(:cp_assessments) }, foreign_key: :cp_assessmentable_id, optional: true
    belongs_to :bank, -> { joins(:cp_assessments) }, foreign_key: :cp_assessmentable_id, optional: true
    belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id'

    has_many :cp_matrices, class_name: 'CP::Matrix', foreign_key: 'cp_assessment_id', inverse_of: :cp_assessment,
                           dependent: :destroy

    scope :latest_first, -> { order(assessment_date: :desc) }
    scope :all_publication_dates, -> { distinct.order(publication_date: :desc).pluck(:publication_date) }
    scope :published_on_or_before, lambda { |publication_date|
      order(:publication_date).where('publication_date <= ?', publication_date)
    }
    scope :currently_published, -> { where('cp_assessments.publication_date <= ?', DateTime.now) }
    scope :regional, -> { where.not(region: [nil, '']) }
    scope :companies, -> { where(cp_assessmentable_type: 'Company') }
    scope :banks, -> { where(cp_assessmentable_type: 'Bank') }

    validates_presence_of :publication_date
    validates_presence_of :last_reported_year, if: -> { emissions&.keys&.any? && cp_assessmentable_type != 'Bank' }
    validates :assessment_date, date_after: Date.new(2010, 12, 31)
    validates :publication_date, date_after: Date.new(2010, 12, 31)
    validates :region, inclusion: {in: REGIONS}, allow_nil: true

    with_options allow_nil: true, allow_blank: true, inclusion: {in: CP::Alignment::ALLOWED_NAMES} do
      validates :cp_alignment_2025
      validates :cp_alignment_2027
      validates :cp_alignment_2028
      validates :cp_alignment_2035
      validates :cp_alignment_2050
      validates :cp_regional_alignment_2025
      validates :cp_regional_alignment_2027
      validates :cp_regional_alignment_2028
      validates :cp_regional_alignment_2035
      validates :cp_regional_alignment_2050
    end

    accepts_nested_attributes_for :cp_matrices, allow_destroy: true, reject_if: :all_blank

    before_validation :prepare_default_values

    def cp_alignment_2025_by_company
      return unless cp_alignment_2025.present?

      CP::Alignment.new(name: cp_alignment_2025, sector: sector&.name)
    end

    def cp_alignment_2027_by_company
      return unless cp_alignment_2027.present?

      CP::Alignment.new(name: cp_alignment_2027, sector: sector&.name)
    end

    def cp_alignment_2028_by_company
      return unless cp_alignment_2028.present?

      CP::Alignment.new(name: cp_alignment_2028, sector: sector&.name)
    end

    def cp_alignment_2035_by_company
      return unless cp_alignment_2035.present?

      CP::Alignment.new(name: cp_alignment_2035, sector: sector&.name)
    end

    def cp_alignment_2050_by_company
      return unless cp_alignment_2050.present?

      CP::Alignment.new(name: cp_alignment_2050, sector: sector&.name)
    end

    def cp_regional_alignment_2025_by_company
      return unless cp_regional_alignment_2025.present?

      CP::Alignment.new(name: cp_regional_alignment_2025, sector: sector&.name)
    end

    def cp_regional_alignment_2027_by_company
      return unless cp_regional_alignment_2027.present?

      CP::Alignment.new(name: cp_regional_alignment_2027, sector: sector&.name)
    end

    def cp_regional_alignment_2028_by_company
      return unless cp_regional_alignment_2028.present?

      CP::Alignment.new(name: cp_regional_alignment_2028, sector: sector&.name)
    end

    def cp_regional_alignment_2035_by_company
      return unless cp_regional_alignment_2035.present?

      CP::Alignment.new(name: cp_regional_alignment_2035, sector: sector&.name)
    end

    def cp_regional_alignment_2050_by_company
      return unless cp_regional_alignment_2050.present?

      CP::Alignment.new(name: cp_regional_alignment_2050, sector: sector&.name)
    end

    def company_subsector
      CompanySubsector.find(company_subsector_id) if company_subsector_id.present?
    end

    def subsector
      company_subsector&.subsector
    end

    def sector
      super || cp_assessmentable.try(:sector)
    end

    def unit
      sector.cp_unit_valid_for_date(publication_date)&.unit
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

    def prepare_default_values
      self.sector_id ||= cp_assessmentable.try(:sector_id)
    end

    def benchmarks
      sector.latest_benchmarks_for_date(publication_date, category: cp_assessmentable_type)
    end

    def regional_benchmarks
      sector.latest_benchmarks_for_date(publication_date, category: cp_assessmentable_type, region: region)
    end
  end
end
