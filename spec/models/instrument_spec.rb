# == Schema Information
#
# Table name: instruments
#
#  id                 :bigint           not null, primary key
#  name               :string
#  instrument_type_id :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#

require 'rails_helper'

RSpec.describe Instrument, type: :model do
  subject { build(:instrument) }

  it { is_expected.to be_valid }

  it 'should be invalid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid without instrument_type' do
    subject.instrument_type = nil
    expect(subject).to have(1).errors_on(:instrument_type)
  end

  it 'should be invalid if name is taken in instrument type scope' do
    type = create(:instrument_type)
    subject.instrument_type = type

    # name taken but for other type
    create(:instrument, name: 'try this name')
    subject.name = 'try this name'
    expect(subject).to be_valid

    create(:instrument, instrument_type: type, name: 'try this name')
    expect(subject).to have(1).errors_on(:name) # now name is taken for the same type
  end
end
