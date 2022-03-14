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
#  legislative_process        :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  visibility_status          :string           default("draft")
#  created_by_id              :bigint
#  updated_by_id              :bigint
#  discarded_at               :datetime
#  percent_global_emissions   :string
#  climate_risk_index         :string
#  wb_income_group            :string
#  external_litigations_count :integer          default(0)
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

  it 'should update slug when editing title' do
    geography = create(:geography, name: 'Some name')
    expect(geography.slug).to eq('some-name')
    geography.update!(name: 'New name')
    expect(geography.slug).to eq('new-name')
  end

  it 'should trip outer div for trix fields before validation' do
    subject.legislative_process = '<div>Some content <div>do not remove this</div></div>'
    expect(subject).to be_valid
    expect(subject.legislative_process).to eq('Some content <div>do not remove this</div>')
  end

  context 'full_text_search' do
    let!(:portugal) {
      create(
        :geography,
        name: 'Portugal',
        region: 'Europe & Central Asia'
      )
    }
    let!(:argentina) {
      create(
        :geography,
        name: 'Argentina',
        region: 'Latin America & Caribbean'
      )
    }
    let!(:austria) {
      create(
        :geography,
        name: 'Austria',
        region: 'Europe & Central Asia'
      )
    }

    it 'uses name' do
      expect(Geography.full_text_search('Argentina')).to contain_exactly(argentina)
    end

    it 'uses region' do
      expect(Geography.full_text_search('europe')).to contain_exactly(austria, portugal)
    end

    it 'uses fuzzy searching' do
      expect(Geography.full_text_search('portuagal')).to contain_exactly(portugal)
    end
  end
end
