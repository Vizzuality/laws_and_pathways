class BankAssessmentResult < ApplicationRecord
  belongs_to :assessment, class_name: 'BankAssessment', foreign_key: :bank_assessment_id
  belongs_to :indicator, class_name: 'BankAssessmentIndicator', foreign_key: :bank_assessment_indicator_id

  validates_presence_of :percentage, if: -> { indicator.percentage_indicator? }
  validates_presence_of :answer, if: -> { indicator.answer_indicator? }

  scope :of_type, ->(type) { includes(:indicator).where(bank_assessment_indicators: {indicator_type: type}) }
end
