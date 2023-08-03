require 'rails_helper'

RSpec.describe Queries::TPI::LatestCPAssessmentsQuery do
  before_all do
    @bank1 = create :bank
    @bank2 = create :bank

    @sector1 = create :tpi_sector, categories: [Bank]
    @sector2 = create :tpi_sector, categories: [Bank]

    @cp_assessment1 = create :cp_assessment, cp_assessmentable: @bank1, sector: @sector1, assessment_date: 1.day.ago
    @cp_assessment2 = create :cp_assessment, cp_assessmentable: @bank1, sector: @sector1, assessment_date: 10.days.ago
    @cp_assessment3 = create :cp_assessment, cp_assessmentable: @bank1, sector: @sector2, assessment_date: 2.days.ago
    @cp_assessment4 = create :cp_assessment, cp_assessmentable: @bank2, sector: @sector1, assessment_date: 1.day.ago

    @cp_not_published = create :cp_assessment, cp_assessmentable: @bank1, sector: @sector1,
                                               assessment_date: 10.minutes.ago, publication_date: 1.day.from_now
    @cp_different_category = create :cp_assessment, cp_assessmentable: create(:company), sector: @sector1
  end

  describe '#call' do
    context 'when just category is provided' do
      subject { described_class.new(category: Bank).call }

      it 'should return the latest cp_assessments for each bank' do
        expect(subject.keys).to contain_exactly([@bank1, @sector1], [@bank1, @sector2], [@bank2, @sector1])
        expect(subject.values.flatten).to match_array([@cp_assessment1, @cp_assessment3, @cp_assessment4])
      end
    end

    context 'when specific cp_assessmentable is provided' do
      subject { described_class.new(category: Bank, cp_assessmentable: @bank1).call }

      it 'should return the latest cp_assessments for the bank' do
        expect(subject.keys).to contain_exactly([@bank1, @sector1], [@bank1, @sector2])
        expect(subject.values.flatten).to contain_exactly(@cp_assessment1, @cp_assessment3)
      end
    end
  end
end
