require 'rails_helper'

RSpec.describe Api::Charts::Sector do
  let(:sector) { create(:tpi_sector, name: 'Airlines') }
  let(:sector2) { create(:tpi_sector, name: 'Autos') }
  let(:company) { create(:company, sector: sector) }
  let(:company2) { create(:company, sector: sector2) }

  subject { described_class.new(Company) }

  before do
    create(
      :mq_assessment,
      assessment_date: '2019-02-01',
      level: '1',
      company: company
    )
    create(
      :mq_assessment,
      assessment_date: '2019-01-01',
      level: '2',
      company: company
    )
    create(
      :mq_assessment,
      company: company2,
      level: '4STAR'
    )
    # should be ignored
    create(
      :mq_assessment,
      assessment_date: '2019-03-01',
      level: '3',
      company: company,
      publication_date: 6.months.from_now
    )
  end

  describe '.companies_summaries_by_level' do
    it 'returns Companies summaries grouped by their level' do
      expect(subject.companies_summaries_by_level).to eq(
        '0' => [],
        '1' => [
          {id: company.id, name: company.name, status: 'down', level: '1'}
        ],
        '2' => [],
        '3' => [],
        '4' => [
          {id: company2.id, name: company2.name, status: 'new', level: '4STAR'}
        ]
      )
    end
  end

  describe '.companies_count' do
    it 'returns companies count grouped by their level' do
      expect(subject.companies_count_by_level).to eq(
        '1' => 1,
        '4' => 1
      )
    end
  end

  describe '.companies_emissions_data' do
    before do
      create(
        :cp_assessment,
        company: company,
        assessment_date: '2019-01-01',
        emissions: {'2017': 70.0, '2018': 110.0, '2019': 100.0},
        publication_date: 6.months.from_now
      ) # ignored
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
      company_data = subject.companies_emissions_data.find { |c| c[:name] == company.name }[:data]
      company2_data = subject.companies_emissions_data.find { |c| c[:name] == company2.name }[:data]

      expect(company_data).to eq(2017 => 90.0, 2018 => 120.0, 2019 => 110.0)
      expect(company2_data).to eq(2017 => 190.0, 2018 => 220.0, 2019 => 90.0)
    end
  end

  describe '.companies_market_cap_by_sector' do
    it 'returns Companies grouped by their sector and level' do
      expect(subject.companies_market_cap_by_sector).to eq(
        'Airlines' => {
          '0' => [],
          '1' => [
            {
              name: company.name,
              slug: company.slug,
              sector: company.sector.name,
              market_cap_group: company.market_cap_group,
              level: company.mq_level.to_i.to_s,
              level4STAR: false
            }
          ],
          '2' => [],
          '3' => [],
          '4' => []
        },
        'Autos' => {
          '0' => [],
          '1' => [],
          '2' => [],
          '3' => [],
          '4' => [
            {
              name: company2.name,
              slug: company2.slug,
              sector: company2.sector.name,
              market_cap_group: company2.market_cap_group,
              level: company2.mq_level.to_i.to_s,
              level4STAR: true
            }
          ]
        }
      )
    end
  end
end
