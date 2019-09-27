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
#  size                      :string
#  ca100                     :boolean          default(FALSE), not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visibility_status         :string           default("draft")
#  discarded_at              :datetime
#

class Company < ApplicationRecord
  include DiscardableModel
  include VisibilityStatus
  extend FriendlyId
  friendly_id :name, use: :slugged, routes: :default

  SIZES = %w[small medium large].freeze

  enum size: array_to_enum_hash(SIZES)

  belongs_to :sector
  belongs_to :geography
  belongs_to :headquarters_geography, class_name: 'Geography'

  has_many :mq_assessments, class_name: 'MQ::Assessment', inverse_of: :company
  has_many :cp_assessments, class_name: 'CP::Assessment', inverse_of: :company
  has_many :litigation_sides, as: :connected_entity
  has_many :litigations, through: :litigation_sides

  delegate :level, :status, :status_description_short,
           to: :latest_assessment, prefix: :mq, allow_nil: true

  validates :ca100, inclusion: {in: [true, false]}
  validates_presence_of :name, :slug, :isin, :size
  validates_uniqueness_of :slug, :isin, :name

  def latest_assessment
    mq_assessments.first
  end

  def to_s
    name
  end
end
