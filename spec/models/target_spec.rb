# == Schema Information
#
# Table name: targets
#
#  id                :bigint           not null, primary key
#  location_id       :bigint
#  sector_id         :bigint
#  target_scope_id   :bigint
#  ghg_target        :boolean          default(FALSE), not null
#  single_year       :boolean          default(FALSE), not null
#  description       :text
#  year              :integer
#  base_year_period  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  target_type       :string
#  visibility_status :string           default("draft")
#

require 'rails_helper'

RSpec.describe Target, type: :model do
  subject { build(:target) }

  it { is_expected.to be_valid }

  it 'should be invalid if ghg_target null' do
    subject.ghg_target = nil
    expect(subject).to have(1).errors_on(:ghg_target)
  end

  it 'should be invalid if single year null' do
    subject.single_year = nil
    expect(subject).to have(1).errors_on(:single_year)
  end

  it 'should be invalid if visibility_status is nil' do
    subject.visibility_status = nil
    expect(subject).to have(1).errors_on(:visibility_status)
  end
end
