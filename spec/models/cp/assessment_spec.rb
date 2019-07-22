# == Schema Information
#
# Table name: cp_assessments
#
#  id               :bigint           not null, primary key
#  company_id       :bigint
#  publication_date :date             not null
#  assessment_date  :date
#  emissions        :jsonb
#  assumptions      :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe CP::Assessment, type: :model do
  subject { build(:cp_assessment) }

  let(:company) { create(:company) }

  it { is_expected.to be_valid }

  it 'should be invalid if publication date is nil' do
    subject.publication_date = nil
    expect(subject).to have(1).errors_on(:publication_date)
  end
end
