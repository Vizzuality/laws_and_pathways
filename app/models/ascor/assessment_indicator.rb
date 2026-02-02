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

  # Returns the best-matched indicator for each code based on assessment date
  # For each code: exact date match > most recent date <= assessment > null date > any available
  def self.for_assessment(assessment)
    date = assessment&.assessment_date
    all_indicators = all.to_a
    codes = all_indicators.map(&:code).uniq

    best_indicators = codes.map do |code|
      candidates = all_indicators.select { |i| i.code == code }
      
      # 1. Exact date match
      exact = candidates.find { |i| i.assessment_date == date }
      next exact if exact

      # 2. Most recent date <= assessment date
      if date.present?
        older = candidates.select { |i| i.assessment_date.present? && i.assessment_date <= date }
        next older.max_by(&:assessment_date) if older.any?
      end

      # 3. Null date (legacy)
      null_date = candidates.find { |i| i.assessment_date.nil? }
      next null_date if null_date

      # 4. Any available (most recent)
      candidates.max_by { |i| i.assessment_date || Date.new(1900, 1, 1) }
    end.compact

    where(id: best_indicators.map(&:id))
  end

  def to_s
    "#{indicator_type} #{code}"
  end
end
