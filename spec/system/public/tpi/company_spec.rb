require 'rails_helper'

describe 'Company Page', type: 'system' do
  before(:each) do
    visit 'tpi/companies/wizz-air'
  end

  it 'loads the page' do
    expect(page).to have_text('Wizz Air')
  end

  it 'shows management quality box' do
    within 'a.summary-box-link[href="#management-quality"]' do
      expect(page).to have_text('Acknowledging Climate Change as a Business Issue')
    end
  end

  it 'shows carbon performance box' do
    within 'a.summary-box-link[href="#carbon-performance"]' do
      expect(page).to have_text('2 Degrees (Shift-Improve)')
    end
  end

  it 'shows company details' do
    expect_company_property('Geography', 'United Kingdom')
    expect_company_property('Sector', 'Airlines')
    expect_company_property('Market cap', 'small')
    expect_company_property('ISIN', 'JE00BN574F90')
    expect_company_property('SEDOL', 'BN574F9')
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

  def contains_class(class_name)
    "contains(concat(' ', normalize-space(@class), ' '), ' #{class_name} ')"
  end
end
