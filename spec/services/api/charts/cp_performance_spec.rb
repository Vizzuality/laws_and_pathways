require 'rails_helper'

RSpec.describe Api::Charts::CPPerformance do
  subject { described_class.new }
  let!(:sector_autos) { create(:tpi_sector, name: 'Autos') }
  let!(:sector_airlines) { create(:tpi_sector, name: 'Airlines') }
  let!(:sector_steel) { create(:tpi_sector, name: 'Steel') }

  describe 'cp_performance' do
    context 'sector has no cp assessments' do
      it 'returns empty list' do
        expect(subject.cp_performance_all_sectors_data).to eq([])
      end
    end

    context 'sector has cp_assessments' do
      before do
        create(
          :company,
          name: 'Auto company 1',
          sector: sector_autos,
          visibility_status: 'published',
          cp_assessments: [
            build(:cp_assessment, cp_alignment: 'Not Aligned', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 6.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'below 2 degrees', assessment_date: 3.months.ago)
          ]
        )

        create(
          :company,
          name: 'Auto company 2',
          sector: sector_autos,
          visibility_status: 'published',
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'Below 2 degrees', assessment_date: 3.months.ago)
          ]
        )

        create(
          :company,
          name: 'Auto company 3',
          sector: sector_autos,
          visibility_status: 'published',
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'Not Aligned', assessment_date: 3.months.ago)
          ]
        )

        create(
          :company,
          name: 'Airline company 1',
          sector: sector_airlines,
          visibility_status: 'published',
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'Paris pledges', assessment_date: 3.months.ago)
          ]
        )

        create(
          :company,
          name: 'Airline company 2',
          sector: sector_airlines,
          visibility_status: 'published',
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'not Aligned', assessment_date: 3.months.ago)
          ]
        )

        create(
          :company,
          name: 'Airline company 3',
          sector: sector_airlines,
          visibility_status: 'published',
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'Paris pledges', assessment_date: 3.months.ago)
          ]
        )


        # map below alignments
        # '2 degrees (high efficiency)' => 'below 2 degrees',
        # '2 degrees (shift-improve)' => '2 degrees',
        # 'international pledges' => 'Paris pledges'

        create(
          :company,
          name: 'Steel company 1',
          sector: sector_steel,
          visibility_status: 'published',
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: '2 degrees (High efficiency)', assessment_date: 3.months.ago)
          ]
        )

        create(
          :company,
          name: 'Steel company 2',
          sector: sector_steel,
          visibility_status: 'published',
          cp_assessments: [
            build(:cp_assessment, cp_alignment: 'Not aligned', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: '2 degrees (shift-improve)', assessment_date: 3.months.ago)
          ]
        )

        create(
          :company,
          name: 'Steel company 3',
          sector: sector_steel,
          visibility_status: 'published',
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'international pledges', assessment_date: 3.months.ago)
          ]
        )
      end

      it 'returns chart data' do
        expect(subject.cp_performance_all_sectors_data).to contain_exactly(
          {
            name: 'Not Aligned',
            data: [['Airlines', 1], ['Autos', 1]]
          },
          {
            name: 'Below 2 Degrees',
            data: [['Autos', 2], ['Steel', 1]]
          },
          {
            name: '2 Degrees',
            data: [['Steel', 1]]
          },
          {
            name: 'Paris Pledges',
            data: [['Airlines', 2], ['Steel', 1]]
          }
        )
      end
    end
  end
end
