# == Schema Information
#
# Table name: cp_assessments
#
#  id                         :bigint           not null, primary key
#  company_id                 :bigint
#  publication_date           :date             not null
#  assessment_date            :date
#  emissions                  :jsonb
#  assumptions                :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  discarded_at               :datetime
#  last_reported_year         :integer
#  cp_alignment               :string
#  cp_alignment_year_override :integer
#  cp_alignment_2025          :string
#  cp_alignment_2035          :string
#  years_with_targets         :integer          is an Array
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

  describe 'cp alignment' do
    it 'should be invalid if cp alignment do not match list' do
      subject.cp_alignment = 'do not match'
      expect(subject).to have(1).errors_on(:cp_alignment)
    end

    it 'should be valid if cp alignment is blank' do
      subject.cp_alignment = nil
      expect(subject).to be_valid
    end

    it 'should be valid if cp alignment is nil' do
      subject.cp_alignment = nil
      expect(subject).to be_valid
    end

    it 'should be valid if cp alignment is on the list' do
      subject.cp_alignment = 'Below 2 Degrees'
      expect(subject).to be_valid
    end
  end

  describe 'cp alignment year' do
    before do
      # this is not taken, it's too old
      create(:cp_benchmark,
             scenario: 'Paris Pledge',
             release_date: 12.months.ago,
             sector: sector)
      # this is not taken, different scenario
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

    describe 'when alignement is not consistent' do
      subject do
        build(
          :cp_assessment,
          cp_alignment: 'Paris Pledge',
          company: company,
          assessment_date: 3.months.ago,
          publication_date: 3.months.ago,
          emissions: {'2016' => 100.5, '2017' => 126.0, '2018' => 99.0, '2019' => 97.0}
        )
      end

      it 'returns the highest consistent alignement year' do
        expect(subject.cp_alignment_year).to eq(2018)
      end
    end

    describe 'when it was align in the past but wont be in future' do
      subject do
        build(
          :cp_assessment,
          cp_alignment: 'Paris Pledge',
          company: company,
          assessment_date: 3.months.ago,
          publication_date: 3.months.ago,
          emissions: {'2016' => 100.5, '2017' => 126.0, '2018' => 100.0, '2019' => 120.0}
        )
      end

      it 'returns nil' do
        expect(subject.cp_alignment_year).to be_nil
      end
    end

    describe 'when it was align in the past' do
      subject do
        build(
          :cp_assessment,
          cp_alignment: 'Paris Pledge',
          company: company,
          assessment_date: 3.months.ago,
          publication_date: 3.months.ago,
          emissions: {'2016' => 100.5, '2017' => 113.0, '2018' => 99.0, '2019' => 97.0}
        )
      end

      it 'returns that past date' do
        expect(subject.cp_alignment_year).to eq(2016)
      end
    end

    describe 'when emission data is missing' do
      subject do
        build(
          :cp_assessment,
          cp_alignment: 'Paris Pledge',
          company: company,
          assessment_date: 3.months.ago,
          publication_date: 3.months.ago,
          emissions: {'2015' => 45, '2016' => 80, '2017' => nil, '2018' => 99.0, '2019' => 97.0, '2020' => 76}
        )
      end

      it 'should ignore years of missing data' do
        expect(subject.cp_alignment_year).to eq(2016)
      end
    end
  end
end
