FactoryBot.define do
  factory :ascor_assessment, class: 'ASCOR::Assessment' do
    country factory: :ascor_country
    assessment_date { Date.new(2021, 9, 10) }
    publication_date { Date.new(2022, 1) }
    notes { 'Research notes' }
  end
end
