module CCLOW
  class ClimateTargetsController < CCLOWController
    include FilterController

    # rubocop:disable Metrics/AbcSize
    def index
      add_breadcrumb('Climate Change Laws of the World', cclow_root_path)
      add_breadcrumb('Climate Targets', cclow_climate_targets_path)
      add_breadcrumb('Search results', request.path) if params[:q].present? || params[:recent].present?

      @climate_targets = CCLOW::TargetDecorator.decorate_collection(
        Queries::CCLOW::TargetQuery.new(filter_params).call
      )

      respond_to do |format|
        format.html do
          render component: 'pages/cclow/ClimateTargets', props: {
            geo_filter_options: region_geography_options,
            tags_filter_options: tags_options('Target'),
            types_filter_options: target_types_options,
            climate_targets: @climate_targets.first(10),
            count: @climate_targets.count
          }, prerender: false
        end
        format.json { render json: {climate_targets: @climate_targets.last(10), count: @climate_targets.count} }
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
