# == Schema Information
#
# Table name: ascor_countries
#
#  id                      :bigint           not null, primary key
#  name                    :string
#  slug                    :string
#  iso                     :string
#  region                  :string
#  wb_lending_group        :string
#  fiscal_monitor_category :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  type_of_party           :string
#
FactoryBot.define do
  factory :ascor_country, class: 'ASCOR::Country' do
    name { 'United States' }
    iso { 'USA' }
    region { 'North America' }
    wb_lending_group { 'High-income' }
    fiscal_monitor_category { 'Advanced economies' }
    type_of_party { 'Annex I' }
  end
end
