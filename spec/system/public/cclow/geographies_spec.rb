require 'rails_helper'

describe 'Geography page', type: 'system' do
  before do
    visit 'cclow/geographies/china'
  end

  it 'loads the page' do
    expect(page).to have_text('China')
  end

  describe 'Overview and context' do
    it 'shows indicators' do
      expect_indicator_value('Laws', '4')
      expect_indicator_value('Policies', '5')
      expect_indicator_value('Litigation cases', '0')
      expect_indicator_value('Climate targets', '57')
    end

    it 'shows geography other data' do
      expect(page).to have_text('East Asia & Pacific') # region
      expect(page).to have_text('G77; G20') # Main political groups
      expect(page).to have_text('Federative 22 provinces, 5 autonomus regions')
    end

    it 'shows timeline' do
      within('.timeline-events-container') do
        expect(page).to have_text('Last amendment')
        expect(page).to have_text('Entry into force')
      end
    end

    it 'shows the map' do
      expect(page).to have_selector('.world-map__container')
    end
  end

  describe 'Laws' do
    before do
      click_link 'Laws (4)'
    end

    it 'shows geography laws page' do
      expect(page).to have_current_path('/cclow/geographies/china/laws')
      expect(page).to have_text('Law on the Prevention and Control of Atmospheric Pollution')
      expect(page).to have_text('Energy Conservation Law')
    end

    describe 'Single law page' do
      before do
        click_link 'Renewable Energy Act (Legislative)'
      end

      it 'shows the page' do
        expect(page).to have_current_path('/cclow/geographies/china/laws/renewable-energy-act-legislative')
        expect(page).to have_text('This Act describes duties of the government')
        expect(page).to have_text('Legislative')
        expect(page).to have_text('Action plan')
        expect(page).to have_text('Mitigation Framework')
        expect(page).to have_text('Passed in 2006')

        within('.timeline-events-container') do
          expect(page).to have_text('Law passed')
          expect(page).to have_text('Last amendment')
        end
      end
    end
  end

  describe 'Policies' do
    before do
      click_link 'Policies (5)'
    end

    it 'shows geography policies page' do
      expect(page).to have_current_path('/cclow/geographies/china/policies')
      expect(page).to have_text('13th Five-Year Plan')
      expect(page).to have_text('Energy Development Strategy Action Plan (2014-2020)')
    end

    describe 'Single policy page' do
      before do
        click_link '13th Five-Year Plan'
      end

      it 'shows the page' do
        expect(page).to have_current_path('/cclow/geographies/china/policies/13th-five-year-plan')
        expect(page).to have_text('The 13th Five Year Plan lays down the strategy and pathway')
        expect(page).to have_text('Executive')
        expect(page).to have_text('Action plan')
        expect(page).to have_text('Mitigation Framework')
        expect(page).to have_text('Passed in 2016')

        within('.timeline-events-container') do
          expect(page).to have_text('Law passed')
        end

        expect(page).to have_text('10 targets')

        expect(page).to have_text(
          'Ensure that the natural shoreline does not fall below 35% by 2020 against a 2015 baseline'
        )
        expect(page).to have_text('Reduce CO2 emissions per unit of GDP by 18% by 2020 against a 2015 baseline')
      end
    end
  end

  describe 'Litigation cases' do
    before do
      click_link 'Litigation cases (0)'
    end

    it 'shows geography litigation cases page' do
      expect(page).to have_text('Currently there are no litigation cases available for China.')
    end
  end

  describe 'Climate targets' do
    before do
      click_link 'Climate targets (57)'
    end

    it 'shows geography climate targets page' do
      expect(page).to have_text('Energy')
      expect(page).to have_text('Transportation')
    end

    describe 'Sector targets' do
      before do
        click_link 'Energy'
      end

      it 'shows the page' do
        expect(page).to have_text('Climate targets: Energy')
        headers = all('.climate-targets-section .nav')

        expect(headers[0]).to have_text('NDC content')
        expect(headers[0]).to have_text('4 targets')
        expect(headers[1]).to have_text('National laws and policies')
        expect(headers[1]).to have_text('22 targets')
      end
    end
  end

  def expect_indicator_value(indicator, expected_value)
    within('.overview-section') do
      within(
        :xpath,
        "(.//div[#{contains_class('indicator')} and contains(., '#{indicator}')]/..)[1]"
      ) do
        expect(page).to have_text(expected_value)
      end
    end
  end
end