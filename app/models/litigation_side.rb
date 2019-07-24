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

  enum side_type: array_to_enum_hash(SIDE_TYPES)
  enum party_type: array_to_enum_hash(PARTY_TYPES)

  validates_presence_of :side_type, :party_type

  belongs_to :litigation
end
