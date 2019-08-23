# == Schema Information
#
# Table name: external_legislations
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  url          :string
#  geography_id :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe ExternalLegislation, type: :model do
  subject { build(:external_legislation) }

  it { is_expected.to be_valid }

  it 'should be invalid without name' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end
end
