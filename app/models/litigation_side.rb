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

  belongs_to :litigation
end
