module CCLOW
  class ClimateTargetsController < CCLOWController
    include SearchController
    include FilterController

    def index
      add_breadcrumb('Litigation cases', cclow_climate_targets_path)
      add_breadcrumb('Search results', request.path) if params[:ids].present?
      @climate_targets = ::Api::Filters.new('Target', filter_params).call.published
      @climate_targets = CCLOW::TargetDecorator.decorate_collection(@climate_targets)
      respond_to do |format|
        format.html do
          render component: 'pages/cclow/ClimateTargets', props: {
            geo_filter_options: region_geography_options,
            tags_filter_options: tags_options('Target'),
            climate_targets: @climate_targets.first(10),
            count: @climate_targets.count
          }, prerender: false
        end
        format.json { render json: {climate_targets: @climate_targets.last(10), count: @climate_targets.count} }
      end
    end
  end
end
