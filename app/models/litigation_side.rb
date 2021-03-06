# == Schema Information
#
# Table name: litigation_sides
#
#  id                    :bigint           not null, primary key
#  litigation_id         :bigint
#  name                  :string
#  side_type             :string           not null
#  party_type            :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  connected_entity_type :string
#  connected_entity_id   :bigint
#  discarded_at          :datetime
#

class LitigationSide < ApplicationRecord
  include DiscardableModel

  SIDE_TYPES = %w[a b c].freeze
  PARTY_TYPES = %w[
    government
    corporation
    intervening_party
    individual_ngo
    individual_government
    individual_corporation
    corporation_individuals
    tribal_government
    corporation_ngo
    individual
    ngo
  ].freeze

  enum side_type: array_to_enum_hash(SIDE_TYPES)
  enum party_type: array_to_enum_hash(PARTY_TYPES)

  belongs_to :litigation
  belongs_to :connected_entity, polymorphic: true, optional: true

  validates_presence_of :side_type, :name
  validates_uniqueness_of :name, scope: [:litigation_id, :side_type]

  def connected_with
    return unless connected_entity.present?

    "#{connected_entity.class}-#{connected_entity.id}"
  end

  def connected_with=(connected_with_string)
    if connected_with_string.present?
      klass, id = connected_with_string.split('-')
      self.connected_entity_type = klass
      self.connected_entity_id = id
    else
      self.connected_entity = nil
    end
  end

  def self.available_connections
    (Company.all.select(:id, :name) + Geography.all.select(:id, :name))
      .map { |c| [c.name, "#{c.class}-#{c.id}"] }
  end
end
