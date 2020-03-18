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

  factory :scope do
    type { 'Scope' }

    sequence(:name) { |n|
      [
        'Energy Intensity',
        'Energy Access',
        'Transport: General',
        'Energy Efficiency',
        'Renewable Energy',
        'Energy: General',
        'Fuel Efficiency',
        'Transportation Fuels',
        'General',
        'Afforestation'
      ].sample << n.to_s
    }
  end

  factory :document_type do
    type { 'DocumentType' }
  end

  factory :response do
    type { 'Response' }
  end

  factory :framework do
    type { 'Framework' }
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
