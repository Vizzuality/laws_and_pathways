require 'rails_helper'

describe 'Sector', type: 'system', site: 'tpi' do
  describe 'all sectors page' do
    before do
      visit '/sectors'
    end

    it 'loads all elements' do
      expect(page).to have_text('All sectors')

      # pie chart
      within '.chart--mq-sector-pie-chart' do
        expect(page).not_to have_text('Level 5')
        expect(page).to have_selector('.companies-size', text: '111')
      end

      # bubble chart loads
      within '.bubble-chart__container' do
        expect(page).not_to have_text('Level 5')
        expect(page).to have_text('Autos')
        expect(page).to have_text('Airlines')
      end
    end

    it 'loads also beta scores' do
      with_mq_beta_scores do
        within '.chart--mq-sector-pie-chart' do
          expect(page).to have_text('Level 5')
        end

        within '.bubble-chart__container' do
          expect(page).to have_text('Level 5')
        end
      end
    end
  end

  describe 'single sector page' do
    before do
      visit '/sectors/airlines'
    end

    it 'loads all elements' do
      # bubble chart loads
      within '.chart--mq-sector-pie-chart' do
        expect(page).to have_text('Level 0 ? 0 companies', normalize_ws: true) # Level 0 0 companies
        expect(page).to have_text('Level 1 ? 2 companies', normalize_ws: true) # Level 1 2 companies
        expect(page).to have_text('Level 2 ? 0 companies', normalize_ws: true) # Level 2 0 companies
        expect(page).to have_text('Level 3 ? 2 companies', normalize_ws: true) # Level 3 2 companies
        expect(page).to have_text('Level 4 ? 1 company', normalize_ws: true) # Level 4 1 company
        expect(page).not_to have_text('Level 5') # BETA level that is disabled by default
        expect(page).to have_selector('.companies-size', text: '5')
      end
    end

    it 'loads also beta scores' do
      with_mq_beta_scores do
        within '.chart--mq-sector-pie-chart' do
          expect(page).to have_text('Level 5')
        end
      end
    end
  end
end
