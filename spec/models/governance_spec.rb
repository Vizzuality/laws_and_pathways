# == Schema Information
#
# Table name: governances
#
#  id                 :bigint           not null, primary key
#  name               :string
#  governance_type_id :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#

require 'rails_helper'

RSpec.describe Governance, type: :model do
  subject { build(:governance) }

  it { is_expected.to be_valid }

  it 'should be invalid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid without governance_type' do
    subject.governance_type = nil
    expect(subject).to have(1).errors_on(:governance_type)
  end
end
