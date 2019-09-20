class CompaniesController < ApplicationController
  def show
    @company = Company.find(params[:id])

    @company_details = ::Api::Charts::Company.new.details_data(@company)
  end

  # Data:     Company emissions
  # Section:  CP
  # Type:     line chart
  # On pages: :show
  def emissions
    @company = Company.find(params[:id])

    data = ::Api::Charts::Company.new.emissions_data(@company)

    render json: data.chart_json
  end
end
