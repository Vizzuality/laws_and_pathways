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

      fixed_navbar('All laws and policies', admin_legislations_path)

      respond_to do |format|
        format.html do
          render component: 'pages/cclow/LegislationAndPolicies', props: {
            geo_filter_options: region_geography_options,
            keywords_filter_options: tags_options('Legislation', 'Keyword'),
            responses_filter_options: tags_options('Legislation', 'Response'),
            frameworks_filter_options: tags_options('Legislation', 'Framework'),
            natural_hazards_filter_options: tags_options('Legislation', 'NaturalHazards'),
            types_filter_options: legislation_types_options,
            instruments_filter_options: instruments_options,
            governances_filter_options: governances_options,
            sectors_options: sectors_options('Legislation'),
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
          legislations = Legislation.includes(
            :frameworks, :document_types, :keywords,
            :natural_hazards, :responses,
            :parent, :geography, :events
          ).where(id: @legislations.pluck(:id))

          render csv: CSVExport::User::Legislations.new(legislations).call,
                 filename: "laws_and_policies_#{timestamp}"
        end
      end
    end

    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength
  end
end
