# == Schema Information
#
# Table name: ascor_assessments
#
#  id               :bigint           not null, primary key
#  country_id       :bigint           not null
#  assessment_date  :date
#  publication_date :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  notes            :text
#
require 'rails_helper'

RSpec.describe ASCOR::Assessment, type: :model do
  subject { build(:ascor_assessment) }

  it { is_expected.to be_valid }

  it 'should be invalid without assessment_date' do
    subject.assessment_date = nil
    expect(subject).to have(1).errors_on(:assessment_date)
  end
end
