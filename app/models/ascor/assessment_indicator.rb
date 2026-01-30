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
#  assessment_date        :date
#
class ASCOR::AssessmentIndicator < ApplicationRecord
  INDICATOR_TYPES = %w[pillar area indicator metric].freeze
  enum indicator_type: array_to_enum_hash(INDICATOR_TYPES)

  has_many :results, class_name: 'ASCOR::AssessmentResult', foreign_key: :indicator_id, dependent: :destroy

  validates_presence_of :indicator_type, :code, :text

  scope :by_assessment_date, ->(date) { where(assessment_date: date) }

  def self.for_assessment(assessment)
    date = assessment&.assessment_date
    
    # 1. Try exact date match
    versioned = where(assessment_date: date)
    return versioned if versioned.exists?
    
    # 2. Try most recent date that's <= assessment date
    if date.present?
      latest_date = where('assessment_date <= ?', date).maximum(:assessment_date)
      return where(assessment_date: latest_date) if latest_date.present?
    end
    
    # 3. Fall back to indicators with no date (legacy)
    no_date = where(assessment_date: nil)
    return no_date if no_date.exists?
    
    # 4. Last resort: use most recent available date
    latest_available = maximum(:assessment_date)
    where(assessment_date: latest_available)
  end

  def to_s
    "#{indicator_type} #{code}"
  end
end
