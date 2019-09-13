class SectorsController < ApplicationController
  def index
    # get companies grouped by latest MQ assessments sector's levels
    @companies_data = Company
                        .includes(:mq_assessments)
                        .group_by { |company| company.mq_assessments.order(:assessment_date).first.level }
                        .map { |k,v| ["Level #{k}", v.size]}
  end

  def show
  end
end
