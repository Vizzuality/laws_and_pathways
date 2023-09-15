FactoryBot.define do
  factory :ascor_assessment_result, class: 'ASCOR::AssessmentResult' do
    assessment factory: :ascor_assessment
    indicator factory: :ascor_assessment_indicator
    answer { 'Yes' }
    source_name { 'Source name' }
    source_date { '2021' }
    source_link { 'https://www.google.com' }
  end
end
