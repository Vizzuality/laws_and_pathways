require 'rails_helper'

RSpec.describe Api::Charts::Sector do
  let_it_be(:sector) { create(:tpi_sector, name: 'Airlines') }
  let_it_be(:sector2) { create(:tpi_sector, name: 'Autos') }
  let_it_be(:company) { create(:company, sector: sector) }
  let_it_be(:company2) { create(:company, sector: sector2) }
  let_it_be(:beta_methodology_version) { MQ::Assessment::BETA_METHODOLOGIES.first }
  let_it_be(:beta_level) { MQ::Assessment::BETA_LEVELS_PER_METHODOLOGY[beta_methodology_version].first }

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
    # beta scores
    create(
      :mq_assessment,
      company: company,
      assessment_date: '2020-01-01',
      level: beta_level,
      methodology_version: beta_methodology_version
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
          {id: company.id, name: company.name, status: 'down', level: '1', slug: company.slug}
        ],
        '2' => [],
        '3' => [],
        '4' => [
          {id: company2.id, name: company2.name, status: 'new', level: '4STAR', slug: company2.slug}
        ]
      )
    end
  end

  describe '.companies_count' do
    it 'returns companies count grouped by their level' do
      expect(subject.companies_count_by_level).to eq(
        '0' => 0,
        '1' => 1,
        '2' => 0,
        '3' => 0,
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
        sector.name => {
          '0' => [],
          '1' => [
            {
              name: company.name,
              slug: company.slug,
              path: company.path,
              sector: company.sector.name,
              market_cap_group: company.market_cap_group,
              level: company.mq_level.to_i.to_s,
              level4STAR: false,
              status: company.mq_status
            }
          ],
          '2' => [],
          '3' => [],
          '4' => []
        },
        sector2.name => {
          '0' => [],
          '1' => [],
          '2' => [],
          '3' => [],
          '4' => [
            {
              name: company2.name,
              slug: company2.slug,
              path: company2.path,
              sector: company2.sector.name,
              market_cap_group: company2.market_cap_group,
              level: company2.mq_level.to_i.to_s,
              level4STAR: true,
              status: company2.mq_status
            }
          ]
        }
      )
    end
  end

  context 'when mq beta scores is turned on' do
    subject { described_class.new(Company, enable_beta_mq_assessments: true) }

    describe '.companies_summaries_by_level' do
      it 'returns Companies summaries grouped by their level' do
        expect(subject.companies_summaries_by_level).to eq(
          '0' => [],
          '1' => [],
          '2' => [],
          '3' => [],
          '4' => [
            {id: company2.id, name: company2.name, status: 'new', level: '4STAR', slug: company2.slug}
          ],
          beta_level => [
            {id: company.id, name: company.name, status: 'up', level: beta_level, slug: company.slug}
          ]
        )
      end
    end

    describe '.companies_count' do
      it 'returns companies count grouped by their level' do
        expect(subject.companies_count_by_level).to eq(
          '0' => 0,
          '1' => 0,
          '2' => 0,
          '3' => 0,
          '4' => 1,
          beta_level => 1
        )
      end
    end

    describe '.companies_market_cap_by_sector' do
      it 'returns Companies grouped by their sector and level' do
        expect(subject.companies_market_cap_by_sector).to eq(
          sector.name => {
            '0' => [],
            '1' => [],
            '2' => [],
            '3' => [],
            '4' => [],
            beta_level => [
              {
                name: company.name,
                slug: company.slug,
                path: company.path,
                sector: company.sector.name,
                market_cap_group: company.market_cap_group,
                level: beta_level,
                level4STAR: false,
                status: 'up'
              }
            ]
          },
          sector2.name => {
            '0' => [],
            '1' => [],
            '2' => [],
            '3' => [],
            '4' => [
              {
                name: company2.name,
                slug: company2.slug,
                path: company2.path,
                sector: company2.sector.name,
                market_cap_group: company2.market_cap_group,
                level: company2.mq_level.to_i.to_s,
                level4STAR: true,
                status: company2.mq_status
              }
            ],
            beta_level => []
          }
        )
      end
    end
  end
end
