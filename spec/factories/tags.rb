# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  type       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :keyword do
    type { 'Keyword' }
    sequence(:name) { |n|
      [
        'climate law',
        'climate policy',
        'COP25',
        'COP24',
        'ghg',
        'carbon emission',
        'energy',
        'industry'
      ].sample << n.to_s
    }
  end

  factory :natural_hazard do
    type { 'NaturalHazard' }
    sequence(:name) { |n|
      [
        'avalanche',
        'drought',
        'earthquake',
        'erosion',
        'extreme temperature',
        'flood',
        'landslide',
        'storm surge',
        'tsunami',
        'volcanic activity',
        'wildfire'
      ].sample << n.to_s
    }
  end
end
