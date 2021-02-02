require 'rails_helper'

describe 'Litigation cases search', type: 'system', site: 'cclow' do
  before do
    visit '/litigation_cases'
  end

  it 'loads the page' do
    expect(page).to have_text('Litigation Cases')
    expect(page).to have_text('Showing 204 results')
  end
end
