module CCLOW
  class ClimateTargetsController < CCLOWController
    # rubocop:disable Metrics/AbcSize
    def index
      add_breadcrumb('Climate Targets', cclow_climate_targets_path)
      add_breadcrumb('Search results', request.path) if params[:q].present?

      @climate_targets = CCLOW::TargetDecorator.decorate_collection(
        Queries::CCLOW::TargetQuery.new(params).call
      )

      geography_options = {field_name: 'geography', options: ::Geography.all.map { |l| {value: l.id, label: l.name} }}
      region_options = {field_name: 'region', options: ::Geography::REGIONS.map { |l| {value: l, label: l} }}

      respond_to do |format|
        format.html do
          render component: 'pages/cclow/ClimateTargets', props: {
            filter_option: [region_options, geography_options],
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
