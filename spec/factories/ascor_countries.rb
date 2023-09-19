FactoryBot.define do
  factory :ascor_country, class: 'ASCOR::Country' do
    name { 'United States' }
    iso { 'USA' }
    region { 'North America' }
    wb_lending_group { 'High-income economies' }
    fiscal_monitor_category { 'Advanced economies' }
  end
end
