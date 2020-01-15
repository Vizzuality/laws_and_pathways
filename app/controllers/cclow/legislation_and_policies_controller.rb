module CCLOW
  class LegislationAndPoliciesController < CCLOWController
    include FilterController

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def index
      add_breadcrumb('Climate Change Laws of the World', cclow_root_path)
      add_breadcrumb('Laws and policies', cclow_legislation_and_policies_path(@geography))
      add_breadcrumb('Search results', request.path) if params[:q].present? || params[:recent].present?

      @legislations = Queries::CCLOW::LegislationQuery.new(filter_params).call

      respond_to do |format|
        format.html do
          render component: 'pages/cclow/LegislationAndPolicies', props: {
            geo_filter_options: region_geography_options,
            tags_filter_options: tags_options('Legislation'),
            types_filter_options: legislation_types_options,
            legislations: CCLOW::LegislationDecorator.decorate_collection(@legislations.first(10)),
            count: @legislations.count
          }, prerender: false
        end
        format.json do
          render json: {
            legislations: CCLOW::LegislationDecorator.decorate_collection(
              @legislations.offset(params[:offset] || 0).take(10)
            ),
            count: @legislations.count
          }
        end
        format.csv do
          timestamp = Time.now.strftime('%d%m%Y')

          render csv: CSVExport::User::Legislations.new(@legislations).call,
                 filename: "laws_and_policies_#{timestamp}"
        end
      end
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
