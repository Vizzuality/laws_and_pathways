require 'rails_helper'

describe 'Geography page', type: 'system' do
  before(:context) do
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
