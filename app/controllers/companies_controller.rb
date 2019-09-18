class CompaniesController < ApplicationController
  def show
    @company = Company.find(params[:id])

    @company_info = {
      country: @company.geography.name,
      sector: @company.sector.name,
      market_cap: 'Large',
      isin: @company.isin,
      sedol: 60,
      ca100: @company.ca100 ? 'Yes' : 'No'
    }

    @company_assessments = @company.latest_assessment.questions.group_by { |q| q['level'] }

    @levels_descriptions = {
      '0' => 'Unaware of Climate Change as a Business Issue',
      '1' => 'Acknowledging Climate Change as a Business Issue',
      '2' => 'Building Capacity',
      '3' => 'Integrating into Operational Decision Making',
      '4' => 'Strategic Assessment'
    }
  end
end
