module CCLOW
  module Geography
    class ClimateTargetsController < CCLOWController
      include GeographyController

      def index
        add_breadcrumb('Climate targets', request.path)
        @list = targets_list_by_sector
        @sectors_without_targets = LawsSector.where.not('name IN (?)', @list.pluck(:sector)).pluck(:name).sort
      end

      def show
        @target = ::Target.find(params[:id])
        add_breadcrumb('Climate targets', cclow_geography_climate_targets_path(@geography))
        add_breadcrumb(@target.id, request.path)
      end

      def laws_sector
        add_breadcrumb('Climate targets', request.path)
        @sector = LawsSector.find_by(name: params[:law_sector])
        @ndc_targets = if @geography.eu_member?
                         eu = ::Geography.where(iso: 'EUR').first
                         eu.targets.published.where(source: 'ndc', sector: @sector)
                       else
                         @geography.targets.published.where(source: 'ndc', sector: @sector)
                       end
        @ndc_targets = CCLOW::TargetDecorator.decorate_collection(@ndc_targets)

        @climate_targets = @geography.targets.published.where(sector: @sector).where.not(source: 'ndc')
        @climate_targets = CCLOW::TargetDecorator.decorate_collection(@climate_targets)
        render 'cclow/geography/climate_targets/target_sector'
      end

      private

      def targets_list_by_sector
        @geography.object.laws_per_sector
      end
    end
  end
end
