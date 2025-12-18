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

  attr_accessor :show_beta_mq_assessments

  friendly_id :name, use: [:slugged, :history], routes: :default

  MARKET_CAP_GROUPS = %w[small medium large unlisted undefined].freeze

  enum market_cap_group: array_to_enum_hash(MARKET_CAP_GROUPS)

  belongs_to :sector, class_name: 'TPISector', foreign_key: 'sector_id'
  belongs_to :geography
  belongs_to :headquarters_geography, class_name: 'Geography'

  has_many :mq_assessments, class_name: 'MQ::Assessment', inverse_of: :company
  has_one :latest_mq_assessment_without_beta_methodologies, -> {
    currently_published.without_beta_methodologies.order(publication_date: :desc, methodology_version: :desc, assessment_date: :desc)
  }, class_name: 'MQ::Assessment'
  has_one :latest_mq_assessment_only_beta_methodologies, -> {
    currently_published.only_beta_methodologies.order(publication_date: :desc, methodology_version: :desc, assessment_date: :desc)
  }, class_name: 'MQ::Assessment'
  has_one :latest_mq_assessment, -> { currently_published.order(publication_date: :desc, methodology_version: :desc, assessment_date: :desc) }, class_name: 'MQ::Assessment'
  has_many :cp_assessments, class_name: 'CP::Assessment', as: :cp_assessmentable
  has_one :latest_cp_assessment, -> {
                                   currently_published.order(assessment_date: :desc)
                                 }, class_name: 'CP::Assessment', as: :cp_assessmentable
  has_one :latest_cp_assessment_regional, -> { currently_published.regional.order(assessment_date: :desc) },
          class_name: 'CP::Assessment', as: :cp_assessmentable
  has_many :litigation_sides, as: :connected_entity
  has_many :litigations, through: :litigation_sides
  has_many :company_subsectors

  delegate :level, :status, :status_description_short,
           to: :latest_mq_assessment, prefix: :mq, allow_nil: true
  delegate :cp_alignment_2050, :cp_alignment_2025, :cp_alignment_2027, :cp_alignment_2028, :cp_alignment_2035,
           :cp_regional_alignment_2050, :cp_regional_alignment_2025, :cp_regional_alignment_2027, :cp_regional_alignment_2028,
           :cp_regional_alignment_2035, to: :latest_cp_assessment, allow_nil: true

  validates :ca100, inclusion: {in: [true, false]}
  validates_presence_of :name, :slug, :isin, :market_cap_group
  validates_uniqueness_of :slug, :name

  scope :active, -> { where(active: true) }
  scope :with_latest_mq_v5, -> {
    latest_v5_pub_date = MQ::Assessment
      .where(methodology_version: 5)
      .currently_published
      .maximum(:publication_date)
    
    joins(:mq_assessments)
      .where(mq_assessments: { 
        methodology_version: 5, 
        publication_date: latest_v5_pub_date 
      })
      .distinct
  }

  def latest_cp_assessments_by_subsector
    return if company_subsectors.empty?

    ordered_cp_assessments = cp_assessments.currently_published.order(assessment_date: :desc)
    return if ordered_cp_assessments.empty?

    # means the latest assessment is not for subsectors but for general
    return if ordered_cp_assessments.first.company_subsector_id.blank?

    by_publication = ordered_cp_assessments.group_by(&:publication_date)
    latest_publication_date = by_publication.keys.max

    by_publication[latest_publication_date].filter { |assessment| assessment.company_subsector_id.present? }
  end

  def latest_regional_cp_assessments_by_subsector
    return if company_subsectors.empty?

    ordered_cp_assessments = cp_assessments.currently_published.regional.order(assessment_date: :desc)
    return if ordered_cp_assessments.empty?

    # means the latest assessment is not for subsectors but for general
    return if ordered_cp_assessments.first.company_subsector_id.blank?

    by_publication = ordered_cp_assessments.group_by(&:publication_date)
    latest_publication_date = by_publication.keys.max

    by_publication[latest_publication_date].filter { |assessment| assessment.company_subsector_id.present? }
  end

  def latest_mq_assessment
    return latest_mq_assessment_without_beta_methodologies if show_beta_mq_assessments.blank?

    latest_mq_assessment_only_beta_methodologies || latest_mq_assessment_without_beta_methodologies
  end

  def beta_mq_assessments?
    mq_assessments.only_beta_methodologies.exists?
  end

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

  def is_4_star?
    mq_level.eql?('4STAR')
  end

  def cp_alignment_region
    latest_cp_assessment_regional&.region
  end

  def path
    Rails.application.routes.url_helpers.tpi_company_path(slug)
  end

  def self.search(query)
    where('name ilike ? OR company_comments_internal ilike ?',
          "%#{query}%", "%#{query}%")
  end
end
