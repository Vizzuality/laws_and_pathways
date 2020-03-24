module CCLOW
  class ClimateTargetsController < CCLOWController
    include FilterController
    def index
      add_breadcrumb('Climate Change Laws of the World', cclow_root_path)
      add_breadcrumb('Climate Targets', cclow_climate_targets_path)
      add_breadcrumb('Search results', request.path) if params[:q].present? || params[:recent].present?

      @climate_targets = Queries::CCLOW::TargetQuery.new(filter_params).call

      fixed_navbar('Climate targets', admin_targets_path)

      respond_to do |format|
        format.html do
          render component: 'pages/cclow/ClimateTargets', props: {
            geo_filter_options: region_geography_options,
            types_filter_options: target_types_options,
            climate_targets: CCLOW::TargetDecorator.decorate_collection(@climate_targets.first(10)),
            count: @climate_targets.size
          }, prerender: false
        end
        format.json do
          render json: {
            climate_targets: CCLOW::TargetDecorator.decorate_collection(
              @climate_targets.offset(params[:offset] || 0).take(10)
            ),
            count: @climate_targets.size
          }
        end
        format.csv do
          timestamp = Time.now.strftime('%d%m%Y')
          target_ids = @climate_targets.reorder(:id).pluck(:id)
          render csv: CSVExport::User::Targets.new(target_ids).call,
                 filename: "climate_targets_#{timestamp}"
        end
      end
    end
  end
end
