require 'rails_helper'

RSpec.describe Api::Charts::Sector do
  let(:sector) { create(:tpi_sector) }
  let(:company) { create(:company, sector: sector) }
  let(:company2) { create(:company, sector: sector) }

  subject { described_class.new(Company) }

  before do
    create(
      :mq_assessment,
      assessment_date: '2019-02-01',
      level: 1,
      company: company
    )
    create(
      :mq_assessment,
      assessment_date: '2019-01-01',
      level: 2,
      company: company
    )
    create(
      :mq_assessment,
      company: company2
    )
  end

  describe '.companies_summaries' do
    it 'returns Companies summaries grouped by their level' do
      expect(subject.companies_summaries_by_level).to eq(
        '0' => [],
        '1' => [
          {id: company.id, name: company.name, status: 'down', level4STAR: false},
          {id: company2.id, name: company2.name, status: 'new', level4STAR: false}
        ],
        '2' => [],
        '3' => [],
        '4' => []
      )
    end
  end

  describe '.companies_count' do
    it 'returns companies count grouped by their level' do
      expect(subject.companies_count_by_level).to eq('1' => 2)
    end
  end

  describe '.companies_emissions_data' do
    before do
      create(
        :cp_assessment,
        company: company,
        assessment_date: '2019-01-01',
        emissions: {'2017': 90.0, '2018': 120.0, '2019': 110.0}
      )
      create(
        :cp_assessment,
        company: company2,
        assessment_date: '2019-01-01',
        emissions: {'2017': 190.0, '2018': 220.0, '2019': 90.0}
      )
    end

    it 'returns companies emissions' do
      expect(subject.companies_emissions_data).to eq(
        [
          {
            data: {'2017' => 90.0, '2018' => 120.0, '2019' => 110.0},
            lineWidth: 4,
            name: company.name
          },
          {
            data: {'2017' => 190.0, '2018' => 220.0, '2019' => 90.0},
            lineWidth: 4,
            name: company2.name
          }
        ]
      )
    end
  end
end
