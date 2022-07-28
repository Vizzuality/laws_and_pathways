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
#
require 'rails_helper'

RSpec.describe BankAssessmentIndicator, type: :model do
  subject { build(:bank_assessment_indicator) }

  it { is_expected.to be_valid }
end
