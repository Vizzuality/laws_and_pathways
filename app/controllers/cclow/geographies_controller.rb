module CCLOW
  class GeographiesController < ApplicationController
    before_action :set_geography, :set_geography_overview

    def show
    end

    def laws
      @legislations = @geography.legislations.executive
    end

    def policies
      @legislations = @geography.legislations.legislative
    end

    def litigation_cases
    end

    def climate_targets
    end

    private

    def set_geography
      @geography = Geography.find(params[:id])
    end

    def set_geography_overview
      @geography_overview = GeographyOverviewDecorator.new(@geography)
    end
  end
end
