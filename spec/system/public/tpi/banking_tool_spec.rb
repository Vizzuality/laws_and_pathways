require 'rails_helper'

describe 'Banking Tool', type: 'system', site: 'tpi' do
  describe 'all banks page' do
    before do
      visit '/banks'
    end

    it 'loads the page' do
      expect(page).to have_text('Average bank score across each area')
    end

    it 'loads average bank score chart' do
      within '.chart--bank-average-score' do
        expect(page).to have_selector('text', text: '1. Net zero commitment')
      end
    end

    it 'loads bubble chart' do
      within '.bubble-chart__container' do
        expect(page).to have_text('Market cap')
        expect(page).to have_text('1. Net zero commitment')
        expect(page).to have_text('2. Target methodology')
      end
    end
  end

  describe 'single bank page' do
    before do
      visit '/banks/edge-bank-inc'
    end

    it 'loads the page' do
      expect(page).to have_text('Edge Bank Inc.')
    end

    it 'shows bank details' do
      expect_property('Geography', 'Australia')
      expect_property('Sector', 'Banks')
      expect_property('Market cap', 'large')
      expect_property('ISIN', 'AU34343243')
      expect_property('SEDOL', '304323')
    end

    it 'shows assessment results' do
      within_banking_area 'Net zero commitment' do
        expect(page).to have_selector('.bank-assessment__area-value-value', text: '25%')
      end

      within_banking_area 'Target methodology' do
        expect(page).to have_selector('.bank-assessment__area-value-value', text: '25%')
      end

      within_banking_area 'Decarbonisation strategy' do
        expect(page).to have_selector('.bank-assessment__area-value-value', text: '0%')
      end
    end

    it 'shows latest information' do
      expect(page).to have_text('Another example of latest information')
    end
  end
end
