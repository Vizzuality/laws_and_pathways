class CompaniesController < ApplicationController
  def show
    @company = Company.find(params[:id])

    @company_details = ::Api::Companies::Details.new(@company).get
  end

  # Returns array of 2 elements:
  # - company emissions
  # - company's sector emissions
  #
  # @example
  #   [
  #     { name: 'Air China', data: {'2014' => 111.0, '2015' => 112.0 } },
  #     { name: 'Airlines sector mean', data: {'2014' => 114.0, '2015' => 112.0 } }
  #   ]
  #
  def emissions
    @company = Company.find(params[:id])

    data = ::Api::Companies::Emissions.new(@company).get

    # TODO: move to JS
    @min_y_axis_value = data.pluck(:data).first.values.min - 20

    render json: data.chart_json
  end
end
