FactoryBot.define do
  factory :cp_unit, class: CP::Unit do
    association :sector, factory: :tpi_sector

    unit { 'unit' }
  end
end
