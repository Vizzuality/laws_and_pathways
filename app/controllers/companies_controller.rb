class CompaniesController < ApplicationController
  def show
    @company = Company.find(params[:id])

    @company_details = ::Api::Presenters::Company.new(@company).company_details
  end

  # Data:     Company emissions
  # Section:  CP
  # Type:     line chart
  # On pages: :show
  def emissions_chart_data
    @company = Company.find(params[:id])

    data = ::Api::Charts::Company.new(@company).emissions_data

    render json: data.chart_json
  end
end
