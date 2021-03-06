require 'rails_helper'

describe 'Company Page', type: 'system', site: 'tpi' do
  before(:each) do
    visit '/companies/japan-airlines'
  end

  it 'loads the page' do
    expect(page).to have_text('Japan Airlines')
  end

  it 'shows management quality box' do
    within 'a.summary-box-link[href="#management-quality"]' do
      expect(page).to have_text('Integrating into Operational Decision Making')
    end
  end

  it 'shows carbon performance box' do
    within 'a.summary-box-link[href="#carbon-performance"]' do
      expect(page).to have_text('Not aligned')
    end
  end

  it 'shows company details' do
    expect_company_property('Geography', 'Japan')
    expect_company_property('Sector', 'Airlines')
    expect_company_property('Market cap', 'large')
    expect_company_property('ISIN', 'JP3705200008')
    expect_company_property('SEDOL', 'B8BRV46')
  end

  it 'shows mq level assessment chart' do
    expect(page).to have_selector('.chart--mq-level svg')
  end

  it 'shows carbon performance chart' do
    expect(page).to have_selector('.chart--cp-performance svg')
  end

  def expect_company_property(property, text)
    within(
      :xpath,
      "(.//div[#{contains_class('company-property__name')} and contains(., '#{property}')]/..)[1]"
    ) do
      expect(page).to have_text(text)
    end
  end
end
