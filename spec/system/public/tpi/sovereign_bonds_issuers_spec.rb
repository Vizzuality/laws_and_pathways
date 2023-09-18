require 'rails_helper'

describe 'Sovereign bonds issuers', type: 'system', site: 'tpi' do
  describe 'all countries page' do
    before do
      visit '/sovereign_bonds_issuers'
    end

    it 'loads the page' do
      expect(page).to have_text('All countries')
    end
  end

  describe 'single country page' do
    before do
      visit '/sovereign_bonds_issuers/japan'
    end
  end
end
