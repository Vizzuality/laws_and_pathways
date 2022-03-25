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
#  cp_alignment_2050          :string
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

  %w[cp_alignment_2025 cp_alignment_2035 cp_alignment_2050].each do |cp_alignment|
    describe cp_alignment do
      it 'should be invalid if cp alignment do not match list' do
        subject.send("#{cp_alignment}=", 'do not match')
        expect(subject).to have(1).errors_on(cp_alignment.to_sym)
      end

      it 'should be valid if cp alignment 2050 is nil' do
        subject.send("#{cp_alignment}=", nil)
        expect(subject).to be_valid
      end

      it 'should be valid if cp alignment 2050 is on the list' do
        subject.send("#{cp_alignment}=", 'Below 2 Degrees')
        expect(subject).to be_valid
      end
    end
  end
end
