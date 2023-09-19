FactoryBot.define do
  factory :ascor_assessment, class: 'ASCOR::Assessment' do
    country factory: :ascor_country
    assessment_date { 1.year.ago }
    publication_date { 11.months.ago }
    research_notes { 'Research notes' }
    further_information { 'Further information' }
  end
end
