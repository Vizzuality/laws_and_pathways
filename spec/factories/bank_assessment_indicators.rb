FactoryBot.define do
  factory :bank_assessment_indicator, class: BankAssessmentIndicator do
    indicator_type { 'area' }
    text { 'Commitment' }
    number { '1' }
  end
end
