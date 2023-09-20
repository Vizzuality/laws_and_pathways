FactoryBot.define do
  factory :ascor_assessment_result, class: 'ASCOR::AssessmentResult' do
    assessment factory: :ascor_assessment
    indicator factory: :ascor_assessment_indicator
    answer { 'Yes' }
    source { 'https://www.google.com' }
    year { '2018' }
  end
end
