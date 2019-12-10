module CCLOW
  class LitigationCasesController < CCLOWController
    # rubocop:disable Metrics/AbcSize
    def index
      add_breadcrumb('Climate Change Laws of the World', cclow_root_path)
      add_breadcrumb('Litigation cases', cclow_litigation_cases_path(@geography))
      add_breadcrumb('Search results', request.path) if params[:q].present? || params[:recent].present?

      @litigations = CCLOW::LitigationDecorator.decorate_collection(
        Queries::CCLOW::LitigationQuery.new(params).call
      )
      geography_options = {
        field_name: 'geography', options: ::Geography.published.map { |l| {value: l.id, label: l.name} }
      }
      region_options = {field_name: 'region', options: ::Geography::REGIONS.map { |l| {value: l, label: l} }}

      respond_to do |format|
        format.html do
          render component: 'pages/cclow/LitigationCases', props: {
            filter_option: [region_options, geography_options],
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
