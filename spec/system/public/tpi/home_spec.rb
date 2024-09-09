require 'rails_helper'

describe 'Home', type: 'system', site: 'tpi' do
  before do
    visit '/'
  end

  it 'loads the page' do
    expect(page).to have_text('TPI Centre')
    expect(page).to have_text('TPI Ltd')
  end
end
