class Bank < ApplicationRecord
  extend FriendlyId

  friendly_id :name, use: [:slugged, :history], routes: :default

  MARKET_CAP_GROUPS = %w[small medium large unlisted].freeze
  enum market_cap_group: array_to_enum_hash(MARKET_CAP_GROUPS)

  belongs_to :geography
  has_many :assessments, class_name: 'BankAssessment'

  validates_presence_of :name, :slug, :isin, :market_cap_group
  validates_uniqueness_of :slug, :name

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
end
