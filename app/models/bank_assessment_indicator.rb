class BankAssessmentIndicator < ApplicationRecord
  INDICATOR_TYPES = %w[area sub_area indicator sub_indicator].freeze
  enum indicator_type: array_to_enum_hash(INDICATOR_TYPES)

  validates_presence_of :number, :text
  validates_uniqueness_of :number, scope: [:indicator_type]

  def percentage_indicator?
    area? || indicator?
  end

  def answer_indicator?
    sub_indicator?
  end
end
