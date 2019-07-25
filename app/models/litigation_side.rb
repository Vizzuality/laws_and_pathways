# == Schema Information
#
# Table name: litigation_sides
#
#  id            :bigint           not null, primary key
#  litigation_id :bigint
#  name          :string
#  side_type     :string           not null
#  party_type    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class LitigationSide < ApplicationRecord
  SIDE_TYPES = %w[a b c].freeze
  PARTY_TYPES = %w[
    government
    corporation
    intervening_party
    individual
    ngo
  ].freeze
  SYSTEM_TYPES = %w[location company other].freeze

  enum side_type: array_to_enum_hash(SIDE_TYPES)
  enum party_type: array_to_enum_hash(PARTY_TYPES)
  enum system_type: array_to_enum_hash(SYSTEM_TYPES)

  belongs_to :litigation
  belongs_to :company, optional: true
  belongs_to :location, optional: true

  before_validation :clear_location, unless: :location?
  before_validation :clear_company, unless: :company?
  before_validation :set_name, if: -> { location? || company? }

  validates_presence_of :side_type, :party_type, :system_type, :name
  validates :company_id, presence: true, if: :company?
  validates :location_id, presence: true, if: :location?
  validates :name, presence: true, if: :other?

  def connected_with
    return "Company-#{company_id}" if company_id.present?
    return "Location-#{location_id}" if location_id.present?
  end

  def connected_with=(connected_with_string)
    if connected_with_string.present?
      klass, id = connected_with_string.split('-')
      self.location_id = id if klass == 'Location'
      self.company_id = id if klass == 'Company'
    else
      self.location = nil
      self.company = nil
    end
  end

  def self.available_connections
    (Company.all + Location.all).map { |c| [c.name, "#{c.class}-#{c.id}"] }
  end

  private

  def clear_name
    self.name = nil
  end

  def clear_location
    self.location = nil
  end

  def clear_company
    self.company = nil
  end
end
