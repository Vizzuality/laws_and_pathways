module CCLOW
  module Geography
    class ClimateTargetsController < CCLOWController
      include GeographyController

      def index
        add_breadcrumb('Climate targets', request.path)
        @list = targets_list_by_sector
        @sectors_without_targets = LawsSector.where.not('name IN (?)', @list.pluck(:sector)).pluck(:name).sort

        fixed_navbar(
          "Climate targets - #{@geography.name}",
          admin_targets_path('q[geography_id_eq]': @geography)
        )
      end

      def show
        @target = ::Target.find(params[:id])
        add_breadcrumb('Climate targets', cclow_geography_climate_targets_path(@geography.slug))
        add_breadcrumb(@target.id, request.path)

        fixed_navbar(
          "Climate targets - #{@geography.name} - #{@target}",
          admin_target_path(@target)
        )
      end

      def laws_sector
        @sector = LawsSector.find_by(name: params[:law_sector])
        @ndc_targets = if @geography.eu_member?
                         eu_sector_ndc_targets
                       else
                         @geography.targets.published.where(source: 'ndc', sector: @sector)
                       end
        @ndc_targets = CCLOW::TargetDecorator.decorate_collection(@ndc_targets)

        @climate_targets = @geography.targets.published.where(sector: @sector).where.not(source: 'ndc')
        @climate_targets = CCLOW::TargetDecorator.decorate_collection(@climate_targets)

        fixed_navbar(
          "Climate targets - #{@geography.name} - #{@sector&.name}",
          admin_targets_path('q[geography_id_eq]': @geography, 'q[sector_id_eq]': @sector)
        )

        add_breadcrumbs
        render 'cclow/geography/climate_targets/target_sector'
      end

      private

      def targets_list_by_sector
        @geography.object.laws_per_sector
      end

      def eu_sector_ndc_targets
        ::Geography.eu_ndc_targets.select { |target| target.sector.eql?(@sector) }
      end

      def add_breadcrumbs
        add_breadcrumb('Climate targets', cclow_geography_climate_targets_path(@geography.slug))
        add_breadcrumb(@sector&.name, request.path) if @sector
      end
    end
  end
end
