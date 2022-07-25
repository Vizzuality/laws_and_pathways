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
  belongs_to :assessment, class_name: 'BankAssessment', foreign_key: :bank_assessment_id
  belongs_to :indicator, class_name: 'BankAssessmentIndicator', foreign_key: :bank_assessment_indicator_id

  validates_presence_of :percentage, if: -> { indicator.percentage_indicator? }
  validates_presence_of :answer, if: -> { indicator.answer_indicator? }

  scope :of_type, ->(type) { includes(:indicator).where(bank_assessment_indicators: {indicator_type: type}) }
  scope :by_date, ->(date) { includes(:assessment).where(bank_assessments: {assessment_date: date}) }

  def value=(val)
    self.answer = val if indicator.answer_indicator?
    self.percentage = val if indicator.percentage_indicator?
  end
end
