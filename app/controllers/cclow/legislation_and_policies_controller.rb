module CCLOW
  class LegislationAndPoliciesController < CCLOWController
    include SearchController
    include FilterController

    def index
      add_breadcrumb('Litigation cases', cclow_legislation_and_policies_path(@geography))
      add_breadcrumb('Search results', request.path) if params[:ids].present?
      @legislations = ::Api::Filters.new('Legislation', filter_params).call.published
      @legislations = CCLOW::LegislationDecorator.decorate_collection(@legislations)
      respond_to do |format|
        format.html do
          render component: 'pages/cclow/LegislationAndPolicies', props: {
            geo_filter_options: region_geography_options,
            tags_filter_options: tags_options('Legislation'),
            legislations: @legislations.first(10),
            count: @legislations.count
          }, prerender: false
        end
        format.json { render json: {legislations: @legislations.last(10), count: @legislations.count} }
      end
    end
  end
end
