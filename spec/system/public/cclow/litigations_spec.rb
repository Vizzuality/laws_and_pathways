require 'rails_helper'

describe 'Litigation cases search', type: 'system' do
  before do
    visit 'cclow/litigation_cases'
  end

  it 'loads the page' do
    expect(page).to have_text('All Litigation Cases')
    expect(page).to have_text('Showing 317 results')
  end
end
