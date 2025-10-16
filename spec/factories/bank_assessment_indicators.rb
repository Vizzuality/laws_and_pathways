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
    text { 'Net zero commitment' }
    number { '1' }

    trait :area do
      indicator_type { 'area' }
    end

    trait :indicator do
      indicator_type { 'indicator' }
      number { '1.1' }
      text { 'Has the bank committed to achieve net-zero emissions?' }
    end

    trait :sub_indicator do
      indicator_type { 'sub_indicator' }
      number { '1.1.a' }
      text { 'Has the bank committed to achieving net zero financed/facilitated emissions by 2050 or sooner?' }
    end

    trait :targets do
      indicator_type { 'area' }
      number { '2' }
      text { 'Targets' }
    end

    trait :exposure_disclosure do
      indicator_type { 'area' }
      number { '3' }
      text { 'Exposure and emissions disclosure' }
    end

    trait :decarbonisation_strategy do
      indicator_type { 'area' }
      number { '5' }
      text { 'Decarbonisation strategy' }
    end

    trait :climate_solutions do
      indicator_type { 'area' }
      number { '6' }
      text { 'Climate solutions' }
    end

    trait :climate_policy_engagement do
      indicator_type { 'area' }
      number { '7' }
      text { 'Climate policy engagement' }
    end

    trait :climate_governance do
      indicator_type { 'area' }
      number { '8' }
      text { 'Climate governance' }
    end

    trait :just_transition do
      indicator_type { 'area' }
      number { '9' }
      text { 'Just transition' }
    end
  end
end
