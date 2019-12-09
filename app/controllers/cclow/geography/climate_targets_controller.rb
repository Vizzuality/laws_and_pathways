module CCLOW
  module Geography
    class ClimateTargetsController < CCLOWController
      include GeographyController

      def index
        add_breadcrumb('Climate targets', request.path)
        @ndc_targets = if @geography.eu_member?
                         eu = ::Geography.where(iso: 'EUR').first
                         eu.targets.published.where(source: 'ndc')
                       else
                         @geography.targets.published.where(source: 'ndc')
                       end
        @climate_targets = @geography.targets.published.where.not(source: 'ndc')
      end

      def show
        @target = ::Target.find(params[:id])
        add_breadcrumb('Climate targets', cclow_geography_climate_targets_path(@geography))
        add_breadcrumb(@target.id, request.path)
      end
    end
  end
end
