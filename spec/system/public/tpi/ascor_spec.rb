require 'rails_helper'

describe 'ASCOR', type: 'system', site: 'tpi' do
  describe 'all countries page' do
    before do
      visit '/ascor'
    end

    it 'loads the page' do
      expect(page).to have_text('All countries')
    end

    it 'loads bubble chart' do
      within '.bubble-chart__container' do
        expect(page).to have_text('1. Emissions Pathways')
        expect(page).to have_text('2. Climate Policies')
        expect(page).to have_text('3. Climate Finance')

        expect(page).to have_text('EP 1. Emissions Trends')
        expect(page).to have_text('CP 1. Climate Legislation')
        expect(page).to have_text('CF 1. International Climate Finance')
      end
    end
  end

  describe 'single country page' do
    before do
      visit '/ascor/japan'
    end
  end
end
