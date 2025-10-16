# == Schema Information
#
# Table name: bank_assessment_results
#
#  id                           :bigint           not null, primary key
#  bank_assessment_id           :bigint
#  bank_assessment_indicator_id :bigint
#  answer                       :string
#  percentage                   :float
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
class BankAssessmentResult < ApplicationRecord
  ANSWERS = ['Yes', 'No', 'Not applicable'].freeze

  belongs_to :assessment, class_name: 'BankAssessment', foreign_key: :bank_assessment_id
  belongs_to :indicator, class_name: 'BankAssessmentIndicator', foreign_key: :bank_assessment_indicator_id

  validates_presence_of :percentage, if: -> { indicator.percentage_indicator? }
  validates :answer, inclusion: {in: ANSWERS}, if: -> { indicator.answer_indicator? }

  # Use version-specific indicators based on assessment date
  scope :of_type, ->(type) {
    includes(:assessment, :indicator)
      .where(bank_assessment_indicators: {indicator_type: type})
      .where('bank_assessment_indicators.version = CASE
        WHEN bank_assessments.assessment_date >= ? THEN ?
        WHEN bank_assessments.assessment_date >= ? THEN ?
        ELSE ?
      END', Date.new(2025, 1, 1), '2025', Date.new(2024, 1, 1), '2024', '2024')
  }

  # Scope for all results (including inactive indicators)
  scope :of_type_all, ->(type) {
    includes(:indicator)
      .where(bank_assessment_indicators: {indicator_type: type})
  }

  scope :by_date, ->(date) { includes(:assessment).where(bank_assessments: {assessment_date: date}) }
  scope :with_active_indicators, -> { joins(:indicator).where(bank_assessment_indicators: {active: true}) }
  scope :with_version, ->(version) { joins(:indicator).where(bank_assessment_indicators: {version: version}) }
  scope :with_assessment_version, -> {
    joins(:assessment, :indicator)
      .where('bank_assessment_indicators.version = CASE
        WHEN bank_assessments.assessment_date >= ? THEN ?
        WHEN bank_assessments.assessment_date >= ? THEN ?
        ELSE ?
      END', Date.new(2025, 1, 1), '2025', Date.new(2024, 1, 1), '2024', '2024')
  }

  def value=(val)
    self.answer = val if indicator.answer_indicator?
    self.percentage = val if indicator.percentage_indicator?
  end
end
