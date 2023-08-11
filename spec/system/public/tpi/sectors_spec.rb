require 'rails_helper'

describe 'Sector', type: 'system', site: 'tpi' do
  describe 'all sectors page' do
    before do
      visit '/sectors'
    end

    it 'loads all elements' do
      expect(page).to have_text('Management Quality: All sectors')

      # pie chart
      within '.chart--mq-sector-pie-chart' do
        expect(page).to have_selector('.companies-size', text: '111')
      end

      # bubble chart loads
      within '.bubble-chart__container' do
        expect(page).to have_text('Market cap')
        expect(page).to have_text('Autos')
        expect(page).to have_text('Airlines')
      end

      # all sectors chart TODO: readd this
      # within '#cp-performance-all-sectors-chart' do
      #   expect(page).to have_text('Below 2 Degrees')
      #   expect(page).to have_text('Aluminium')
      #   expect(page).to have_text('Cement')
      # end
    end
  end

  describe 'single sector page' do
    before do
      visit '/sectors/airlines'
    end

    it 'loads all elements' do
      # bubble chart loads
      within '.chart--mq-sector-pie-chart' do
        expect(page).to have_text('Level 32 companies') # Level 3 2 companies
        expect(page).to have_selector('.companies-size', text: '5')
      end
    end
  end
end
