# == Schema Information
#
# Table name: sectors
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  slug       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cp_unit    :text
#

require 'rails_helper'

RSpec.describe Sector, type: :model do
  subject { build(:sector) }

  it { is_expected.to be_valid }

  it 'should not be valid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should not be valid if name taken' do
    create(:sector, name: 'Airlines')
    expect(build(:sector, name: 'Airlines')).to have(1).errors_on(:name)
  end
end
