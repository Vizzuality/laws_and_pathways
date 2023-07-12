# == Schema Information
#
# Table name: instrument_types
#
#  id           :bigint           not null, primary key
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

require 'rails_helper'

RSpec.describe InstrumentType, type: :model do
  subject { build(:instrument_type) }

  it { is_expected.to be_valid }

  it 'should be invalid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid if name is taken' do
    create(:instrument_type, name: 'instrument_type')
    subject.name = 'instrument_type'
    expect(subject).to have(1).errors_on(:name)
  end
end
