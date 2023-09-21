FactoryBot.define do
  factory :ascor_assessment_indicator, class: ASCOR::AssessmentIndicator do
    indicator_type { 'area' }
    text { 'Emissions Trends' }
    code { 'EP.1' }
    units_or_response_type { 'Yes/No/Partial' }
  end
end
