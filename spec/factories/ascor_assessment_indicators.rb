# == Schema Information
#
# Table name: ascor_assessment_indicators
#
#  id                     :bigint           not null, primary key
#  indicator_type         :string
#  code                   :string
#  text                   :text
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  units_or_response_type :string
#
FactoryBot.define do
  factory :ascor_assessment_indicator, class: ASCOR::AssessmentIndicator do
    indicator_type { 'area' }
    text { 'Emissions Trends' }
    code { 'EP.1' }
    units_or_response_type { 'Yes/No/Partial' }
  end
end
