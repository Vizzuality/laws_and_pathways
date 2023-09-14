class ASCOR::AssessmentIndicator < ApplicationRecord
  INDICATOR_TYPES = %w[pillar area indicator custom_indicator].freeze
  enum indicator_type: array_to_enum_hash(INDICATOR_TYPES)

  validates_presence_of :indicator_type, :code, :text
end
