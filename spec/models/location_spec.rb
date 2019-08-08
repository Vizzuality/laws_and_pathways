# == Schema Information
#
# Table name: locations
#
#  id                         :bigint           not null, primary key
#  location_type              :string           not null
#  iso                        :string           not null
#  name                       :string           not null
#  slug                       :string           not null
#  region                     :string           not null
#  federal                    :boolean          default(FALSE), not null
#  federal_details            :text
#  approach_to_climate_change :text
#  legislative_process        :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  visibility_status          :string           default("draft")
#  indc_url                   :text
#

require 'rails_helper'

RSpec.describe Location, type: :model do
  subject { build(:location) }

  it { is_expected.to be_valid }

  it 'should be invalid if iso is nil' do
    subject.iso = nil
    expect(subject).to have(1).errors_on(:iso)
  end

  it 'should be invalid if name is nil' do
    subject.name = nil
    expect(subject).to have(1).errors_on(:name)
  end

  it 'should be invalid if region is nil' do
    subject.region = nil
    expect(subject).to have(1).errors_on(:region)
  end

  it 'should be invalid if location_type is wrong' do
    expect {
      subject.location_type = 'WRONG'
    }.to raise_error(ArgumentError)
  end

  it 'should be invalid if visibility_status is nil' do
    subject.visibility_status = nil
    expect(subject).to have(1).errors_on(:visibility_status)
  end

  it 'should be invalid if indc_url is not a valid URL' do
    subject.indc_url = 'not a valid external_url'
    expect(subject).to have(1).errors_on(:indc_url)
  end
end
