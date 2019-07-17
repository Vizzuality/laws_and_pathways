# == Schema Information
#
# Table name: companies
#
#  id                      :bigint(8)        not null, primary key
#  location_id             :bigint(8)
#  headquarter_location_id :bigint(8)
#  sector_id               :bigint(8)
#  name                    :string           not null
#  slug                    :string           not null
#  isin                    :string           not null
#  size                    :string
#  ca100                   :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class Company < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  SIZES = %w[small medium large].freeze
  enum size: array_to_enum_hash(SIZES)

  belongs_to :sector
  belongs_to :location
  belongs_to :headquarter_location, class_name: 'Location'

  has_many :mq_assessments, class_name: 'MQ::Assessment', inverse_of: :company
  has_many :cp_assessments, class_name: 'CP::Assessment', inverse_of: :company

  delegate :level, :status, :status_description_short,
           to: :latest_assessment, prefix: :mq, allow_nil: true

  validates :ca100, inclusion: {in: [true, false]}
  validates_presence_of :name, :slug, :isin, :size
  validates_uniqueness_of :slug, :isin

  def latest_assessment
    mq_assessments.first
  end
end
