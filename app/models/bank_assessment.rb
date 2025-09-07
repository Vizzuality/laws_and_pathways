# == Schema Information
#
# Table name: bank_assessments
#
#  id              :bigint           not null, primary key
#  bank_id         :bigint
#  assessment_date :date             not null
#  notes           :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class BankAssessment < ApplicationRecord
  belongs_to :bank
  has_many :results, class_name: 'BankAssessmentResult', dependent: :destroy

  validates_presence_of :assessment_date
  validates :assessment_date, date_after: Date.new(2010, 12, 31)

  def indicator_version
    return '2025' if assessment_date >= Date.new(2025, 1, 1)
    return '2024' if assessment_date >= Date.new(2024, 1, 1)

    '2024'
  end

  def results_by_indicator_type
    results.joins(:indicator)
      .where(bank_assessment_indicators: {version: indicator_version})
      .order('bank_assessment_indicators.number')
      .group_by { |r| r.indicator.indicator_type }
  end

  def all_results_by_indicator_type
    # Method to get results from all indicators (including inactive)
    results.includes(:indicator)
      .order('bank_assessment_indicators.number')
      .group_by { |r| r.indicator.indicator_type }
  end

  def active_results_by_indicator_type
    results_by_indicator_type
  end

  def version_results_by_indicator_type
    results_by_indicator_type
  end

  def active_results?
    results.joins(:indicator).where(bank_assessment_indicators: {version: indicator_version}).exists?
  end

  def legacy_results?
    results.joins(:indicator).where(bank_assessment_indicators: {version: indicator_version}).exists?
  end

  # Class method to get assessment dates that have actual data (oldest first)
  def self.dates_with_data
    joins(:results)
      .joins(
        'JOIN bank_assessment_indicators ON bank_assessment_indicators.id = bank_assessment_results.bank_assessment_indicator_id'
      )
      .where('bank_assessment_indicators.version = CASE
        WHEN bank_assessments.assessment_date >= ? THEN ?
        WHEN bank_assessments.assessment_date >= ? THEN ?
        ELSE ?
      END', Date.new(2025, 1, 1), '2025', Date.new(2024, 1, 1), '2024', '2024')
      .select(:assessment_date)
      .distinct
      .order(:assessment_date)
      .pluck(:assessment_date)
  end
end
