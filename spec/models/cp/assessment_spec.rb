# == Schema Information
#
# Table name: cp_assessments
#
#  id                         :bigint           not null, primary key
#  publication_date           :date             not null
#  assessment_date            :date
#  emissions                  :jsonb
#  assumptions                :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  discarded_at               :datetime
#  last_reported_year         :integer
#  cp_alignment_2050          :string
#  cp_alignment_2025          :string
#  cp_alignment_2035          :string
#  years_with_targets         :integer          is an Array
#  region                     :string
#  cp_regional_alignment_2025 :string
#  cp_regional_alignment_2035 :string
#  cp_regional_alignment_2050 :string
#  cp_assessmentable_type     :string
#  cp_assessmentable_id       :bigint
#  sector_id                  :bigint
#  final_disclosure_year      :integer
#  cp_alignment_2027          :string
#  cp_regional_alignment_2027 :string
#  cp_alignment_2028          :string
#  cp_regional_alignment_2028 :string
#

require 'rails_helper'

RSpec.describe CP::Assessment, type: :model do
  let_it_be(:sector) { create(:tpi_sector) }
  let_it_be(:company) { create(:company, sector: sector) }

  subject { build(:cp_assessment, cp_assessmentable: company) }

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

  it 'should be invalid with wrong region' do
    subject.region = 'wrong'
    expect(subject).to have(1).errors_on(:region)
  end

  it 'should be invalid with empty region' do
    subject.region = ''
    expect(subject).to have(1).errors_on(:region)
  end

  it 'should be valid with nil region' do
    subject.region = nil
    expect(subject).to be_valid
  end

  %w[
    cp_alignment_2025
    cp_alignment_2027
    cp_alignment_2028
    cp_alignment_2035
    cp_alignment_2050
    cp_regional_alignment_2025
    cp_regional_alignment_2027
    cp_regional_alignment_2028
    cp_regional_alignment_2035
    cp_regional_alignment_2050
  ].each do |cp_alignment|
    describe cp_alignment do
      it 'should be invalid if cp alignment do not match list' do
        subject.send("#{cp_alignment}=", 'do not match')
        expect(subject).to have(1).errors_on(cp_alignment.to_sym)
      end

      it "should be valid if #{cp_alignment} is nil" do
        subject.send("#{cp_alignment}=", nil)
        expect(subject).to be_valid
      end

      it "should be valid if #{cp_alignment} is on the list" do
        subject.send("#{cp_alignment}=", 'Below 2 Degrees')
        expect(subject).to be_valid
      end
    end
  end

  describe '#cp_benchmark_id' do
    let(:chemicals_sector) { create(:tpi_sector, name: 'Chemicals', categories: %w[Company]) }
    let(:company_a) { create(:company, sector: chemicals_sector) }
    let(:company_b) { create(:company, sector: chemicals_sector) }
    let(:subsector_a) { CompanySubsector.create!(company: company_a, subsector: 'BASF') }
    let(:subsector_b) { CompanySubsector.create!(company: company_b, subsector: 'Company A') }
    let(:release_date) { Date.new(2026, 5, 10) }
    let!(:benchmark_a) do
      create(:cp_benchmark,
             sector: chemicals_sector,
             category: 'Company',
             scenario: '1.5 Degrees',
             subsector: 'BASF',
             benchmark_label: 'BASF',
             release_date: release_date)
    end
    let!(:benchmark_b) do
      create(:cp_benchmark,
             sector: chemicals_sector,
             category: 'Company',
             scenario: '1.5 Degrees',
             subsector: 'Company A',
             benchmark_label: 'Company A',
             release_date: release_date)
    end
    let(:assessment_a) do
      create(:cp_assessment,
             sector: chemicals_sector,
             cp_assessmentable: company_a,
             company_subsector_id: subsector_a.id,
             publication_date: release_date,
             assessment_date: release_date)
    end
    let(:assessment_b) do
      create(:cp_assessment,
             sector: chemicals_sector,
             cp_assessmentable: company_b,
             company_subsector_id: subsector_b.id,
             publication_date: release_date,
             assessment_date: release_date)
    end

    it 'returns per-company benchmark id for Chemicals assessments' do
      expect(assessment_a.cp_benchmark_id).to eq(benchmark_a.benchmark_id)
      expect(assessment_b.cp_benchmark_id).to eq(benchmark_b.benchmark_id)
      expect(assessment_a.cp_benchmark_id).not_to eq(assessment_b.cp_benchmark_id)
    end
  end
end
