# == Schema Information
#
# Table name: bank_assessment_indicators
#
#  id             :bigint           not null, primary key
#  indicator_type :string           not null
#  number         :string           not null
#  text           :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  comment        :text
#  is_placeholder :boolean          default(FALSE)
#  version        :string           default("2025")
#  active         :boolean          default(TRUE)
#
class BankAssessmentIndicator < ApplicationRecord
  INDICATOR_TYPES = %w[area sub_area indicator sub_indicator].freeze
  enum indicator_type: array_to_enum_hash(INDICATOR_TYPES)

  validates_presence_of :number, :text
  validates_uniqueness_of :number, scope: [:indicator_type, :version]

  # Scopes for versioning
  scope :active, -> { where(active: true) }
  scope :by_version, ->(version) { where(version: version) }
  scope :current, -> { active.by_version('2025') }
  scope :legacy, -> { by_version('2024') }

  def text_with_number
    return "#{number.chars.last}. #{text}" if answer_indicator?
    return "#{number}: #{text}" if sub_area? || indicator?

    "#{number}. #{text}"
  end

  def display_text
    return text_with_number unless area?

    text
  end

  def percentage_indicator?
    area? || indicator?
  end

  def answer_indicator?
    sub_indicator?
  end
end
