module CCLOW
  class LegislationAndPoliciesController < CCLOWController
    # rubocop:disable Metrics/AbcSize
    def index
      add_breadcrumb('Legislation and policies', cclow_legislation_and_policies_path(@geography))
      add_breadcrumb('Search results', request.path) if params[:q].present?

      @legislations = CCLOW::LegislationDecorator.decorate_collection(
        Queries::CCLOW::LegislationQuery.new(params).call
      )
      geography_options = {field_name: 'geography', options: ::Geography.all.map { |l| {value: l.id, label: l.name} }}
      region_options = {field_name: 'region', options: ::Geography::REGIONS.map { |l| {value: l, label: l} }}

      respond_to do |format|
        format.html do
          render component: 'pages/cclow/LegislationAndPolicies', props: {
            filter_option: [region_options, geography_options],
            legislations: @legislations.first(10),
            count: @legislations.count
          }, prerender: false
        end
        format.json { render json: {legislations: @legislations.last(10), count: @legislations.count} }
      end
    end
    # rubocop:enable Metrics/AbcSize
  end
end
