# == Schema Information
#
# Table name: bank_assessment_indicators
#
#  id             :bigint           not null, primary key
#  indicator_type :string           not null
#  number         :string           not null
#  text           :text             not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  comment        :text
#  is_placeholder :boolean          default(FALSE)
#
FactoryBot.define do
  factory :bank_assessment_indicator, class: BankAssessmentIndicator do
    indicator_type { 'area' }
    text { 'Commitment' }
    number { '1' }
  end
end
