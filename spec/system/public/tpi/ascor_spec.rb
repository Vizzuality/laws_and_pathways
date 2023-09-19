require 'rails_helper'

describe 'ASCOR', type: 'system', site: 'tpi' do
  describe 'all countries page' do
    before do
      visit '/ascor'
    end

    it 'loads the page' do
      expect(page).to have_text('All countries')
    end
  end

  describe 'single country page' do
    before do
      visit '/ascor/japan'
    end
  end
end
