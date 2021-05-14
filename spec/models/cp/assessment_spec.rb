# == Schema Information
#
# Table name: cp_assessments
#
#  id                 :bigint           not null, primary key
#  company_id         :bigint
#  publication_date   :date             not null
#  assessment_date    :date
#  emissions          :jsonb
#  assumptions        :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  discarded_at       :datetime
#  last_reported_year :integer
#  cp_alignment       :string
#

require 'rails_helper'

RSpec.describe CP::Assessment, type: :model do
  let_it_be(:sector) { create(:tpi_sector) }
  let_it_be(:company) { create(:company, sector: sector) }

  subject { build(:cp_assessment, company: company) }

  it { is_expected.to be_valid }

  it 'should be invalid if publication date is nil' do
    subject.publication_date = nil
    expect(subject).to have(1).errors_on(:publication_date)
  end

  it 'should be invalid if assessment date is before 2010' do
    subject.assessment_date = '2001-02-15'
    expect(subject).to have(1).errors_on(:assessment_date)
  end

  it 'should be invalid if publication date is before 2010' do
    subject.publication_date = '2001-02-15'
    expect(subject).to have(1).errors_on(:publication_date)
  end

  it 'should be invalid if emissions present but last reported year not' do
    subject.emissions = {'2019': 344}
    subject.last_reported_year = nil
    expect(subject).to have(1).errors_on(:last_reported_year)
  end

  describe 'cp alignment year' do
    before do
      create(:cp_benchmark,
             scenario: 'Paris Pledge',
             release_date: 12.months.ago,
             sector: sector)
      create(:cp_benchmark,
             scenario: '2 degrees',
             release_date: 7.months.ago,
             sector: sector)
      create(:cp_benchmark,
             scenario: 'Paris Pledge',
             release_date: 7.months.ago,
             sector: sector,
             emissions: {'2016' => 130.5, '2017' => 123.0, '2018' => 100.0, '2019' => 98.0})
    end

    subject do
      build(
        :cp_assessment,
        cp_alignment: 'Paris Pledge',
        company: company,
        assessment_date: 3.months.ago,
        publication_date: 3.months.ago,
        emissions: {'2016' => 140.5, '2017' => 126.0, '2018' => 99.0, '2019' => 97.0}
      )
    end

    it 'returns year when emission is lower than that in benchmark' do
      expect(subject.cp_alignment_year).to eq(2018)
    end

    it 'returns override year when set' do
      subject.cp_alignment_year_override = 2030
      expect(subject.cp_alignment_year).to eq(2030)
    end
  end
end
