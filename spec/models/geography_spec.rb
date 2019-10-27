# == Schema Information
#
# Table name: geographies
#
#  id                         :bigint           not null, primary key
#  geography_type             :string           not null
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
#  created_by_id              :bigint
#  updated_by_id              :bigint
#  discarded_at               :datetime
#

require 'rails_helper'

RSpec.describe Geography, type: :model do
  subject { build(:geography) }

  it { is_expected.to be_valid }

  it 'should be invalid if iso is nil and type is national' do
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

  it 'should be invalid if geography_type is wrong' do
    expect {
      subject.geography_type = 'WRONG'
    }.to raise_error(ArgumentError)
  end

  it 'should be invalid if visibility_status is nil' do
    subject.visibility_status = nil
    expect(subject).to have(2).errors_on(:visibility_status)
  end
end
