require 'rails_helper'

describe 'Home', type: 'system', site: 'cclow' do
  before do
    visit '/'
  end

  it 'loads the page' do
    expect(page).to have_text('Climate Change Laws of the World')

    expect(page).to have_selector('.laws-dropdown__container')
    expect(page).to have_selector('.world-map__container')
  end

  describe 'search dropdown' do
    it 'works' do
      within '.laws-dropdown__container' do
        find('input#search-input').click
        find('input#search-input').set('Polan')

        Capybara.using_wait_time(5) do
          expect(page).to have_text("Search \nPolan\n in Laws and policies\n11")
          expect(page).to have_text("Search \nPolan\n in Litigation\n5")
          expect(page).to have_text("Search \nPolan\n in Climate targets\n11")
        end

        click_link 'Poland'
        expect(page).to have_current_path('/geographies/poland')
      end
    end
  end
end
