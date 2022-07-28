# == Schema Information
#
# Table name: bank_assessment_results
#
#  id                           :bigint           not null, primary key
#  bank_assessment_id           :bigint
#  bank_assessment_indicator_id :bigint
#  answer                       :string
#  percentage                   :float
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
FactoryBot.define do
  factory :bank_assessment_result, class: BankAssessmentResult do
    association :assessment, factory: :bank_assessment
  end
end
