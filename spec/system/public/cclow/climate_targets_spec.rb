require 'rails_helper'

describe 'Climate Targets search', type: 'system', site: 'cclow' do
  before do
    visit '/climate_targets'
  end

  it 'loads the page' do
    expect(page).to have_text('All Climate Targets')
    expect(page).to have_text('Showing 1993 results')
  end
end
