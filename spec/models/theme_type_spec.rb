# == Schema Information
#
# Table name: theme_types
#
#  id           :bigint           not null, primary key
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  discarded_at :datetime
#

require 'rails_helper'

RSpec.describe ThemeType, type: :model do
  subject { build(:theme_type) }

  it { is_expected.to be_valid }

  it 'should be invalid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid if name is taken' do
    create(:theme_type, name: 'theme_type')
    subject.name = 'theme_type'
    expect(subject).to have(1).errors_on(:name)
  end
end
