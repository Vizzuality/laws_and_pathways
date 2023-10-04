require 'rails_helper'

describe 'ASCOR', type: 'system', site: 'tpi' do
  describe 'all countries page' do
    before do
      visit '/ascor'
    end

    it 'loads the page' do
      expect(page).to have_text('All countries')
    end
  end

  describe 'single country page' do
    before do
      visit '/ascor/japan'
    end

    it 'shows assessment results' do
      areas = ASCOR::AssessmentIndicator.area.order(:id)
      ASCOR::AssessmentIndicator.pillar.order(:id).each do |pillar|
        within_ascor_pillar pillar.text do
          areas.select { |a| a.code.include? pillar.code }.each do |area|
            expect(page).to have_text(area.text)
          end
        end
      end
    end
  end
end
