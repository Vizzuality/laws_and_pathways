FactoryBot.define do
  factory :ascor_assessment_indicator, class: ASCOR::AssessmentIndicator do
    indicator_type { 'area' }
    text { 'Commitment' }
    code { 'EP' }
  end
end
