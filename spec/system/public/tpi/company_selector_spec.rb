require 'rails_helper'

describe 'Company Selector', type: 'system', site: 'tpi' do
  before(:each) do
    visit '/sectors'
  end

  it 'filters by company' do
    click_button 'Filter by company'
    find('.dropdown-selector__header').click
    find('input.dropdown-selector__input').set('Toyota')
    find('input.dropdown-selector__input').native.send_keys(:return)
    expect(page).to have_current_path('/companies/toyota')
  end

  it 'filters by sector' do
    click_button 'Filter by sector'
    find('.dropdown-selector__header').click
    find('input.dropdown-selector__input').set('Cement')
    find('input.dropdown-selector__input').native.send_keys(:return)
    expect(page).to have_current_path('/sectors/cement')
  end
end
