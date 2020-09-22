require 'rails_helper'

describe 'Laws and policies search', type: 'system', site: 'cclow' do
  before do
    visit '/legislation_and_policies'
  end

  it 'loads the page' do
    expect(page).to have_text('Laws and policies')
    expect(page).to have_text('Showing 1803 results')
  end
end
