require 'rails_helper'

describe 'Climate Targets search', type: 'system' do
  before do
    visit 'cclow/climate_targets'
  end

  it 'loads the page' do
    expect(page).to have_text('Climate Targets')
    expect(page).to have_text('Showing 1993 results')
  end
end
