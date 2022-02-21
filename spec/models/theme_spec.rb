# == Schema Information
#
# Table name: themes
#
#  id                 :bigint           not null, primary key
#  name               :string
#  theme_type_id :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#

require 'rails_helper'

RSpec.describe Theme, type: :model do
  subject { build(:theme) }

  it { is_expected.to be_valid }

  it 'should be invalid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid without theme_type' do
    subject.theme_type = nil
    expect(subject).to have(1).errors_on(:theme_type)
  end

  it 'should be invalid if name is taken in goevernance type scope' do
    type = create(:theme_type)
    subject.theme_type = type

    # name taken but for other type
    create(:theme, name: 'try this name')
    subject.name = 'try this name'
    expect(subject).to be_valid

    create(:theme, theme_type: type, name: 'try this name')
    expect(subject).to have(1).errors_on(:name) # now name is taken for the same type
  end
end
