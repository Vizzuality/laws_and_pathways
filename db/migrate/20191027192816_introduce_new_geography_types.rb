class IntroduceNewGeographyTypes < ActiveRecord::Migration[5.2]
  class Geography < ApplicationRecord
    GEOGRAPHY_TYPES = %w[
      country
      national
      supranational
    ].freeze

    enum geography_type: array_to_enum_hash(GEOGRAPHY_TYPES)
  end

  def up
    Geography.where(iso: 'EUR').update_all(geography_type: 'supranational')
    Geography.where(geography_type: 'country').update_all(geography_type: 'national')
  end

  def down
    Geography.where(geography_type: ['national', 'supranational']).update_all(geography_type: 'country')
  end
end
