require 'rails_helper'

describe 'Laws and policies search', type: 'system' do
  before do
    visit 'cclow/legislation_and_policies'
  end

  it 'loads the page' do
    expect(page).to have_text('All laws and policies')
    expect(page).to have_text('Showing 1803 results')
  end
end