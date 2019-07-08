# == Schema Information
#
# Table name: mq_assessments
#
#  id               :bigint(8)        not null, primary key
#  company_id       :bigint(8)
#  level            :string           not null
#  notes            :text
#  assessment_date  :date             not null
#  publication_date :date             not null
#  questions        :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

# module FactoryHelper
#   def fake_values(from:, to:, starting_at:)
#     value = starting_at

#     (from..to).map do |year|
#       value -= rand(1..5)
#       {year => value}
#     end.reduce(&:merge)
#   end
#   module_function :fake_values
# end

FactoryBot.define do
  factory :mq_assessment, class: MQ::Assessment do
    association :company

    assessment_date { 1.year.ago }
    publication_date { 11.months.ago }

    level { '1' }
    notes { 'Some notes' }
  end
end
