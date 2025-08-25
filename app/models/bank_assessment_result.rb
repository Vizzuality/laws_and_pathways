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

  # Use only active indicators by default
  scope :of_type, ->(type) {
    includes(:indicator)
      .where(bank_assessment_indicators: {indicator_type: type, active: true})
  }

  # Scope for all results (including inactive indicators)
  scope :of_type_all, ->(type) {
    includes(:indicator)
      .where(bank_assessment_indicators: {indicator_type: type})
  }

  scope :by_date, ->(date) { includes(:assessment).where(bank_assessments: {assessment_date: date}) }
  scope :with_active_indicators, -> { joins(:indicator).where(bank_assessment_indicators: {active: true}) }
  scope :with_version, ->(version) { joins(:indicator).where(bank_assessment_indicators: {version: version}) }

  def value=(val)
    self.answer = val if indicator.answer_indicator?
    self.percentage = val if indicator.percentage_indicator?
  end
end
