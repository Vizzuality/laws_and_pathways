module CCLOW
  class LitigationCasesController < CCLOWController
    include FilterController

    # rubocop:disable Metrics/AbcSize
    def index
      add_breadcrumb('Climate Change Laws of the World', cclow_root_path)
      add_breadcrumb('Litigation cases', cclow_litigation_cases_path(@geography))
      add_breadcrumb('Search results', request.path) if params[:q].present? || params[:recent].present?

      @litigations = CCLOW::LitigationDecorator.decorate_collection(
        Queries::CCLOW::LitigationQuery.new(filter_params).call
      )

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
    # rubocop:enable Metrics/AbcSize
  end
end
