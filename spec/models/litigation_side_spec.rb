# == Schema Information
#
# Table name: litigation_sides
#
#  id                    :bigint           not null, primary key
#  litigation_id         :bigint
#  name                  :string
#  side_type             :string           not null
#  party_type            :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  connected_entity_type :string
#  connected_entity_id   :bigint
#

require 'rails_helper'

RSpec.describe LitigationSide, type: :model do
  subject { build(:litigation_side) }

  it { is_expected.to be_valid }

  it 'should be invalid without side_type' do
    subject.side_type = nil
    expect(subject).to have(1).errors_on(:side_type)
  end

  it 'should be invalid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end
end
