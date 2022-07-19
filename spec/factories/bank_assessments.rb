# == Schema Information
#
# Table name: bank_assessments
#
#  id              :bigint           not null, primary key
#  bank_id         :bigint
#  assessment_date :date             not null
#  notes           :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
FactoryBot.define do
  factory :bank_assessment, class: BankAssessment do
    assessment_date { 1.year.ago.to_date }

    notes { 'Some notes' }
  end
end
