# == Schema Information
#
# Table name: targets
#
#  id                :bigint           not null, primary key
#  geography_id      :bigint
#  ghg_target        :boolean          default(FALSE), not null
#  single_year       :boolean          default(FALSE), not null
#  description       :text
#  year              :integer
#  base_year_period  :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  target_type       :string
#  visibility_status :string           default("draft")
#  created_by_id     :bigint
#  updated_by_id     :bigint
#  discarded_at      :datetime
#  sector_id         :bigint
#  source            :string
#  tsv               :tsvector
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
    expect(subject).to have(2).errors_on(:visibility_status)
  end

  it 'should trip outer div for trix fields before validation' do
    subject.description = '<div>Some content <div>do not remove this</div></div>'
    expect(subject).to be_valid
    expect(subject.description).to eq('Some content <div>do not remove this</div>')
  end

  context 'full_text_search' do
    let!(:target_1) {
      create(
        :target,
        description: "30% obliged entity's energy efficiency requirements implemented by 2016"
      )
    }
    let!(:target_2) {
      create(
        :target,
        description: '35% cut in GHG emissions from biofuels and bioliquids compared to fossil fuels by 2017 Łąka'
      )
    }
    let!(:target_3) {
      create(
        :target,
        description: '63 aggregated energy efficiency ratio by 2020 against a 2000 baseline',
        scopes: [
          build(:scope, name: 'Transport')
        ]
      )
    }

    it 'ignores accents' do
      expect(Target.full_text_search('Laka')).to contain_exactly(target_2)
    end

    it 'uses stemming' do
      expect(Target.full_text_search('comparing')).to contain_exactly(target_2)
    end

    it 'uses description' do
      expect(Target.full_text_search('energy')).to contain_exactly(target_1, target_3)
    end

    it 'uses tags' do
      expect(Target.full_text_search('transport')).to contain_exactly(target_3)
    end
  end
end
