require 'rails_helper'

RSpec.describe Api::Charts::CPPerformance do
  subject { described_class.new }

  describe 'cp_performance' do
    context 'sector has no cp assessments' do
      it 'returns empty list' do
        expect(subject.cp_performance_all_sectors_data).to eq([])
      end
    end

    context 'sector has cp_assessments' do
      let(:cluster_1) { create(:tpi_sector_cluster, name: 'Transport') }
      let(:cluster_2) { create(:tpi_sector_cluster, name: 'Materials') }
      let(:sector_autos) { create(:tpi_sector, name: 'Autos', cluster: cluster_1) }
      let(:sector_airlines) { create(:tpi_sector, name: 'Airlines', cluster: cluster_1) }
      let(:sector_steel) { create(:tpi_sector, name: 'Steel', cluster: cluster_2) }
      let(:sector_no_cluster) { create(:tpi_sector, name: 'Cement') }
      let(:sector_no_cp) { create(:tpi_sector, name: 'No CP') }

      before do
        create(
          :company, :published,
          name: 'Auto company 1',
          sector: sector_autos,
          cp_assessments: [
            build(:cp_assessment, cp_alignment: 'Not Aligned', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 6.months.ago), # ignored
            build(:cp_assessment,
                  cp_alignment: 'below 3 degrees',
                  assessment_date: 2.months.ago,
                  publication_date: 6.months.from_now), # ignored
            build(:cp_assessment, cp_alignment: 'below 2 degrees', assessment_date: 3.months.ago)
          ]
        )

        create(
          :company, :published,
          name: 'Auto company 2',
          sector: sector_autos,
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'Below 2 degrees', assessment_date: 3.months.ago),
            build(:cp_assessment, cp_alignment: 'below 3 degrees',
                                  assessment_date: 2.months.ago,
                                  publication_date: 6.months.from_now) # ignored
          ]
        )

        create(
          :company, :published,
          name: 'Auto company 3',
          sector: sector_autos,
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'Not Aligned', assessment_date: 3.months.ago),
            build(:cp_assessment, cp_alignment: 'below 3 degrees',
                                  assessment_date: 2.months.ago,
                                  publication_date: 6.months.from_now) # ignored
          ]
        )

        create(
          :company, :published,
          name: 'Airline company 1',
          sector: sector_airlines,
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'Paris pledges', assessment_date: 3.months.ago),
            build(:cp_assessment, cp_alignment: '3 degrees',
                                  assessment_date: 2.months.ago,
                                  publication_date: 6.months.from_now) # ignored
          ]
        )

        create(
          :company, :published,
          name: 'Airline company 2',
          sector: sector_airlines,
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'not Aligned', assessment_date: 3.months.ago),
            build(:cp_assessment, cp_alignment: '3 degrees',
                                  assessment_date: 2.months.ago,
                                  publication_date: 6.months.from_now) # ignored
          ]
        )

        create(
          :company, :published,
          name: 'Airline company 3',
          sector: sector_airlines,
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'Paris pledges', assessment_date: 3.months.ago),
            build(:cp_assessment, cp_alignment: '3 degrees',
                                  assessment_date: 2.months.ago,
                                  publication_date: 6.months.from_now) # ignored
          ]
        )

        # map below alignments
        # '2 degrees (high efficiency)' => 'below 2 degrees',
        # '2 degrees (shift-improve)' => '2 degrees',
        # 'international pledges' => 'Paris pledges'

        create(
          :company, :published,
          name: 'Steel company 1',
          sector: sector_steel,
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: '2 degrees (High efficiency)', assessment_date: 3.months.ago),
            build(:cp_assessment, cp_alignment: '3 degrees',
                                  assessment_date: 2.months.ago,
                                  publication_date: 6.months.from_now) # ignored
          ]
        )

        create(
          :company, :published,
          name: 'Steel company 2',
          sector: sector_steel,
          visibility_status: 'published',
          cp_assessments: [
            build(:cp_assessment, cp_alignment: 'Not aligned', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: '2 degrees (shift-improve)', assessment_date: 3.months.ago),
            build(:cp_assessment, cp_alignment: '3 degrees',
                                  assessment_date: 2.months.ago,
                                  publication_date: 6.months.from_now) # ignored
          ]
        )

        create(
          :company, :published,
          name: 'Steel company 3',
          sector: sector_steel,
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'international pledges', assessment_date: 3.months.ago),
            build(:cp_assessment, cp_alignment: '3 degrees',
                                  assessment_date: 2.months.ago,
                                  publication_date: 6.months.from_now) # ignored
          ]
        )

        create(
          :company,
          :published,
          name: 'Cement company 1',
          sector: sector_no_cluster,
          cp_assessments: [
            build(:cp_assessment, cp_alignment: '2 degrees', assessment_date: 12.months.ago), # ignored
            build(:cp_assessment, cp_alignment: 'international pledges', assessment_date: 3.months.ago),
            build(:cp_assessment, cp_alignment: '3 degrees',
                                  assessment_date: 2.months.ago,
                                  publication_date: 6.months.from_now) # ignored
          ]
        )
      end

      it 'returns chart data properly sorted by alignment name and then sector cluster' do
        result = subject.cp_performance_all_sectors_data

        expect(result[0][:name]).to eq('Below 2 Degrees')
        expect(result[0][:data]).to eq([['Steel', 1], ['Airlines', 0], ['Autos', 2], ['Cement', 0]])

        expect(result[1][:name]).to eq('2 Degrees')
        expect(result[1][:data]).to eq([['Steel', 1], ['Airlines', 0], ['Autos', 0], ['Cement', 0]])

        expect(result[2][:name]).to eq('Paris Pledges')
        expect(result[2][:data]).to eq([['Steel', 1], ['Airlines', 2], ['Autos', 0], ['Cement', 1]])

        expect(result[3][:name]).to eq('Not Aligned')
        expect(result[3][:data]).to eq([['Steel', 0], ['Airlines', 1], ['Autos', 1], ['Cement', 0]])

        expect(result[4]).to be_nil
      end
    end
  end
end
