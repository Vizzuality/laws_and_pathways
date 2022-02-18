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

  it 'should be invalid if name is taken in goevernance type scope' do
    type = create(:governance_type)
    subject.governance_type = type

    # name taken but for other type
    create(:governance, name: 'try this name')
    subject.name = 'try this name'
    expect(subject).to be_valid

    create(:governance, governance_type: type, name: 'try this name')
    expect(subject).to have(1).errors_on(:name) # now name is taken for the same type
  end
end
