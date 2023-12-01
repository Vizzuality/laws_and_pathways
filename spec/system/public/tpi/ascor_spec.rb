require 'rails_helper'

describe 'ASCOR', type: 'system', site: 'tpi' do
  describe 'all countries page' do
    before do
      visit '/ascor'
    end

    it 'loads the page' do
      expect(page).to have_text('All countries')
    end

    it 'loads the mobile version of bubble chart  ' do
      for_mobile_screen do
        within all('.bubble-chart__container')[0] do # mobile version
          expect(page).to have_text('Emission Pathways')
          expect(page).to have_text('Climate Policies')
          expect(page).to have_text('Climate Finance')
        end
      end
    end

    it 'loads desktop version of bubble chart' do
      within all('.bubble-chart__container')[1] do # desktop version
        expect(page).to have_text('1. Emission Pathways')
        expect(page).to have_text('2. Climate Policies')
        expect(page).to have_text('3. Climate Finance')

        expect(page).to have_text('EP 1. Emission Trends')
        expect(page).to have_text('CP 1. Climate Legislation')
        expect(page).to have_text('CF 1. International Climate Finance')
      end
    end
  end

  describe 'single country page' do
    before do
      visit '/ascor/japan'
    end

    it 'shows country specific information' do
      expect(page).to have_text('Japan')
      expect(page).to have_text('ISO')
      expect(page).to have_text('JPN')
      expect(page).to have_text('Region')
      expect(page).to have_text('Asia')
      expect(page).to have_text('World Bank lending group')
      expect(page).to have_text('High-income')
      expect(page).to have_text('IMF Fiscal Monitor Category')
      expect(page).to have_text('Advanced economies')
      expect(page).to have_text('Type of Party to the UNFCCC')
      expect(page).to have_text('Annex I')
    end

    it 'shows assessment pillars' do
      ASCOR::AssessmentIndicator.pillar.order(:id).each do |pillar|
        expect(page).to have_text(pillar.text.upcase)
      end
    end

    it 'shows assessment results' do
      find_all('label.country-assessment__more.pillar').each(&:click)
      areas = ASCOR::AssessmentIndicator.area.order(:id)
      ASCOR::AssessmentIndicator.pillar.order(:id).each do |pillar|
        within_ascor_pillar pillar.text do
          areas.select { |a| a.code.include? pillar.code }.each do |area|
            expect(page).to have_text(area.text)
          end
        end
      end
    end

    it 'generates EP.1.a.i and EP.1.a.ii metrics' do
      find_all('label.country-assessment__more.pillar').each(&:click)
      find("label[for='area-ascor_assessment_indicator_#{ASCOR::AssessmentIndicator.find_by(code: 'EP.1').id}']").click
      expect(page).to have_text("i. What is the country's most recent emissions level?")
      expect(page).to have_text("ii. What is the country's most recent emissions trend?")
    end
  end
end
