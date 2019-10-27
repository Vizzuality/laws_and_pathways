module CCLOW
  module GeographyController
    extend ActiveSupport::Concern

    included do
      before_action :set_geography, :set_geography_overview

      layout 'cclow/geography'
    end

    private

    def set_geography
      @geography = Geography.find(params[:geography_id] || params[:id])
    end

    def set_geography_overview
      @geography_overview = GeographyOverviewDecorator.new(@geography)
    end
  end
end
