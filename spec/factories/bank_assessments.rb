FactoryBot.define do
  factory :bank_assessment, class: BankAssessment do
    assessment_date { 1.year.ago.to_date }

    notes { 'Some notes' }
  end
end
