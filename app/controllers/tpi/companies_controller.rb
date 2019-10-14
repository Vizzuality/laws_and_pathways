module Tpi
  class CompaniesController < ApplicationController
    def show
      @company = Company.find(params[:id])

      @company_summary = company_presenter.summary
      @company_mq_assessments = company_presenter.mq_assessments
    end

    # Data:     Nr of Company MQ Assessments
    # Section:  MQ
    # Type:     line chart
    # On pages: :show
    def nr_of_assessments_chart_data
      @company = Company.find(params[:id])

      # TODO: fill in missing years with previous year levels
      data = ::Api::Charts::Company.new(@company).nr_of_assessments_data

      render json: data.chart_json
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

    def company_presenter
      @company_presenter ||= ::Api::Presenters::Company.new(@company)
    end
  end
end
