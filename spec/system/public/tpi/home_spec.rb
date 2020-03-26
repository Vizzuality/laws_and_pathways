require 'rails_helper'

describe 'Home', type: 'system' do
  before do
    visit 'tpi'
  end

  it 'loads the page' do
    expect(page).to have_text('The TPI tool')
  end
end
