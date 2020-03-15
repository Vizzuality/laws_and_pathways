require 'rails_helper'

describe 'Home', type: 'system' do
  before do
    visit 'cclow'
  end

  it 'loads the page' do
    expect(page).to have_text('Climate Change Laws of the World')
  end

  it 'loads laws search component' do
    expect(page).to have_selector('.laws-dropdown__container')
  end

  it 'loads the map' do
    expect(page).to have_selector('.world-map__container')
  end
end
