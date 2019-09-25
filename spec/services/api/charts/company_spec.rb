require 'rails_helper'

RSpec.describe Api::Charts::Company do
  let(:sector) { create(:sector) }
  let(:company) { create(:company, sector: sector) }
  let(:another_company_from_sector) { create(:company, sector: sector) }

  subject { described_class.new(company) }

  describe '.emissions_data' do
    before do
      create(
        :cp_assessment,
        company: company,
        emissions: {'2017' => 90.0, '2018' => 90.0, '2019' => 110.0}
      )
      create(
        :cp_assessment,
        company: another_company_from_sector,
        emissions: {'2017' => 40.0, '2018' => 50.0}
      )
      create(
        :cp_benchmark,
        scenario: 'scenario',
        sector: sector,
        emissions: {'2018' => 124.0, '2017' => 122.0}
      )
    end

    it 'returns all series data' do
      expect(subject.emissions_data).to eq [
        {
          name: company.name,
          data: {'2017' => 90.0, '2018' => 90.0, '2019' => 110.0}
        },
        {
          name: "#{sector.name} sector mean",
          data: {'2017' => 65.0, '2018' => 70.0, '2019' => 110.0}
        },
        {
          type: 'area',
          fillOpacity: 0.1,
          name: 'scenario',
          data: {'2017' => 122.0, '2018' => 124.0}
        }
      ]
    end
  end
end
