# == Schema Information
#
# Table name: ascor_assessment_indicators
#
#  id                     :bigint           not null, primary key
#  indicator_type         :string
#  code                   :string
#  text                   :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  units_or_response_type :string
#
class ASCOR::AssessmentIndicator < ApplicationRecord
  INDICATOR_TYPES = %w[pillar area indicator metric].freeze
  enum indicator_type: array_to_enum_hash(INDICATOR_TYPES)

  has_many :results, class_name: 'ASCOR::AssessmentResult', foreign_key: :indicator_id, dependent: :destroy

  validates_presence_of :indicator_type, :code, :text

  def to_s
    "#{indicator_type} #{code}"
  end
end
