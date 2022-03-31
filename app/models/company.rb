# == Schema Information
#
# Table name: companies
#
#  id                        :bigint           not null, primary key
#  geography_id              :bigint
#  headquarters_geography_id :bigint
#  sector_id                 :bigint
#  name                      :string           not null
#  slug                      :string           not null
#  isin                      :string           not null
#  market_cap_group          :string
#  ca100                     :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  discarded_at              :datetime
#  sedol                     :string
#  latest_information        :text
#  company_comments_internal :text
#  active                    :boolean          default(TRUE)
#

class Company < ApplicationRecord
  include VisibilityStatus
  include DiscardableModel
  include PublicActivityTrackable
  include TPICache
  extend FriendlyId

  friendly_id :name, use: [:slugged, :history], routes: :default

  MARKET_CAP_GROUPS = %w[small medium large unlisted].freeze

  enum market_cap_group: array_to_enum_hash(MARKET_CAP_GROUPS)

  belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id'
  belongs_to :geography
  belongs_to :headquarters_geography, class_name: 'Geography'

  has_many :mq_assessments, class_name: 'MQ::Assessment', inverse_of: :company
  has_one :latest_mq_assessment, -> { currently_published.order(assessment_date: :desc) }, class_name: 'MQ::Assessment'
  has_many :cp_assessments, class_name: 'CP::Assessment', inverse_of: :company
  has_one :latest_cp_assessment, -> { currently_published.order(assessment_date: :desc) }, class_name: 'CP::Assessment'
  has_many :litigation_sides, as: :connected_entity
  has_many :litigations, through: :litigation_sides

  delegate :level, :status, :status_description_short,
           to: :latest_mq_assessment, prefix: :mq, allow_nil: true
  delegate :cp_alignment_2050, :cp_alignment_2025, :cp_alignment_2035,
           :cp_regional_alignment_2050, :cp_regional_alignment_2025, :cp_regional_alignment_2035,
           to: :latest_cp_assessment, allow_nil: true

  validates :ca100, inclusion: {in: [true, false]}
  validates_presence_of :name, :slug, :isin, :market_cap_group
  validates_uniqueness_of :slug, :name

  scope :active, -> { where(active: true) }

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def to_s
    name
  end

  def latest_sector_benchmarks
    sector.latest_released_benchmarks
  end

  def isin_array
    return [] if isin.blank?

    isin.split(',')
  end

  def is_4_star?
    mq_level.eql?('4STAR')
  end

  def cp_alignment_region
    latest_cp_assessment&.region
  end

  def path
    Rails.application.routes.url_helpers.tpi_company_path(slug)
  end

  def self.search(query)
    where('name ilike ? OR company_comments_internal ilike ?',
          "%#{query}%", "%#{query}%")
  end
end
