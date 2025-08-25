# == Schema Information
#
# Table name: banks
#
#  id                 :bigint           not null, primary key
#  geography_id       :bigint
#  name               :string           not null
#  slug               :string           not null
#  isin               :string           not null
#  sedol              :string
#  market_cap_group   :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  latest_information :text
#
class Bank < ApplicationRecord
  include PublicActivityTrackable
  extend FriendlyId

  friendly_id :name, use: [:slugged, :history], routes: :default

  MARKET_CAP_GROUPS = %w[small medium large unlisted].freeze
  enum market_cap_group: array_to_enum_hash(MARKET_CAP_GROUPS)

  belongs_to :geography
  has_many :assessments, class_name: 'BankAssessment', inverse_of: :bank
  has_one :latest_assessment, -> { order(assessment_date: :desc) }, class_name: 'BankAssessment'
  has_many :cp_assessments, class_name: 'CP::Assessment', as: :cp_assessmentable
  has_one :latest_cp_assessment, -> {
    currently_published.order(assessment_date: :desc)
  }, class_name: 'CP::Assessment', as: :cp_assessmentable
  has_one :latest_cp_assessment_regional, -> { currently_published.regional.order(assessment_date: :desc) },
          class_name: 'CP::Assessment', as: :cp_assessmentable

  delegate :cp_alignment_2025, :cp_alignment_2027, :cp_alignment_2028, :cp_alignment_2030, :cp_alignment_2035, :cp_alignment_2050,
           :cp_regional_alignment_2025, :cp_regional_alignment_2027,
           :cp_regional_alignment_2028, :cp_regional_alignment_2030, :cp_regional_alignment_2035,
           :cp_regional_alignment_2050,
           to: :latest_cp_assessment, allow_nil: true

  validates_presence_of :name, :slug, :isin, :market_cap_group
  validates_uniqueness_of :slug, :name

  scope :published, -> { all }

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def to_s
    name
  end

  def isin_array
    return [] if isin.blank?

    isin.split(',')
  end

  def path
    Rails.application.routes.url_helpers.tpi_bank_path(slug)
  end

  def latest_assessment
    assessments.order(assessment_date: :desc).first
  end

  def latest_assessment_with_active_indicators
    assessments.joins(:results)
      .joins('JOIN bank_assessment_indicators ON ' \
             'bank_assessment_indicators.id = bank_assessment_results.bank_assessment_indicator_id')
      .where(bank_assessment_indicators: {active: true})
      .order(assessment_date: :desc)
      .first
  end

  def assessments_with_active_indicators
    assessments.joins(:results)
      .joins('JOIN bank_assessment_indicators ON ' \
             'bank_assessment_indicators.id = bank_assessment_results.bank_assessment_indicator_id')
      .where(bank_assessment_indicators: {active: true})
      .distinct
      .order(assessment_date: :desc)
  end
end
