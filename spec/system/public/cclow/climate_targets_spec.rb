require 'rails_helper'

describe 'Climate Targets search', type: 'system', site: 'cclow' do
  before do
    visit '/climate_targets'
  end

  xit 'loads the page' do
    expect(page).to have_text('Climate Targets')
    expect(page).to have_text('Showing 240 results')
  end
end
