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

  validates_presence_of :side_type, :party_type, :system_type

  belongs_to :litigation
  belongs_to :company, optional: true
  belongs_to :location, optional: true

  before_validation :clear_location, unless: :location?
  before_validation :clear_company, unless: :company?
  before_validation :clear_name, unless: :other?

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
