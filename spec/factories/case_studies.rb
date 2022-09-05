# == Schema Information
#
# Table name: case_studies
#
#  id           :bigint           not null, primary key
#  organization :string           not null
#  link         :string
#  text         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
FactoryBot.define do
  factory :case_study do
    logo { TestFiles.png }
    text { 'I loved the site' }
    organization { 'Company' }
    link { 'https://example.com' }
  end
end
