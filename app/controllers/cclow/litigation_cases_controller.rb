module CCLOW
  class LitigationCasesController < CCLOWController
    include SearchController
    include FilterController

    def index
      add_breadcrumb('Litigation cases', cclow_litigation_cases_path(@geography))
      add_breadcrumb('Search results', request.path) if params[:ids].present?
      @litigations = ::Api::Filters.new('Litigation', filter_params).call.published
      @litigations = CCLOW::LitigationDecorator.decorate_collection(@litigations)
      respond_to do |format|
        format.html do
          render component: 'pages/cclow/LitigationCases', props: {
            geo_filter_options: region_geography_options,
            tags_filter_options: tags_options('Litigation'),
            litigations: @litigations.first(10),
            count: @litigations.count
          }, prerender: false
        end
        format.json { render json: {litigations: @litigations.last(10), count: @litigations.count} }
      end
    end
  end
end
