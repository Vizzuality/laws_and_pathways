module CCLOW
  class LitigationCasesController < CCLOWController
    include SearchController

    # rubocop:disable Metrics/AbcSize
    def index
      add_breadcrumb('Litigation cases', cclow_litigation_cases_path(@geography))
      if params[:ids]
        ids = params[:ids].split(',').map(&:to_i)
        @litigations = CCLOW::LitigationDecorator.decorate_collection(Litigation.find(ids))
        add_breadcrumb('Search results', request.path)
      else
        @litigations = CCLOW::LitigationDecorator.decorate_collection(Litigation.all)
      end
      filter
      geography_options = {field_name: 'geography', options: ::Geography.all.map { |l| {value: l.id, label: l.name} }}
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

    private

    def filter
      if params[:region]
        @litigations = @litigations.includes(:jurisdiction).where(geographies: {region: params[:region]})
      end
      return unless params[:geography]

      @litigations = @litigations.includes(:jurisdiction).where(geographies: {id: params[:geography]})
    end
  end
end
