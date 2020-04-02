module CCLOW
  class LegislationAndPoliciesController < CCLOWController
    include FilterController
    def index
      add_breadcrumb('Climate Change Laws of the World', cclow_root_path)
      add_breadcrumb('Laws and policies', cclow_legislation_and_policies_path)
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
            count: @legislations.size
          }, prerender: false
        end
        format.json do
          render json: {
            items: CCLOW::LegislationDecorator.decorate_collection(
              @legislations.offset(params[:offset] || 0).take(10)
            ),
            count: @legislations.size
          }
        end
        format.csv do
          timestamp = Time.now.strftime('%d%m%Y')
          legislation_ids = @legislations.reorder(:id).pluck(:id)
          render csv: CSVExport::User::Legislations.new(legislation_ids).call,
                 filename: "laws_and_policies_#{timestamp}"
        end
      end
    end
  end
end
