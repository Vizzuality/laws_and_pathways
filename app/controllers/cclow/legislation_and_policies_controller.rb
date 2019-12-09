module CCLOW
  class LegislationAndPoliciesController < CCLOWController
    include SearchController

    # rubocop:disable Metrics/AbcSize
    def index
      add_breadcrumb('Legislation and policies', cclow_legislation_and_policies_path(@geography))
      if params[:fromDate]
        @legislations = CCLOW::LegislationDecorator
          .decorate_collection(Legislation.published.where('updated_at >= ?', params[:fromDate]))
      elsif params[:ids]
        ids = params[:ids].split(',').map(&:to_i)
        @legislations = Legislation.find(ids)
        add_breadcrumb('Search results', request.path)
      else
        @legislations = Legislation.published
      end
      @legislations = CCLOW::LegislationDecorator.decorate_collection(filter(@legislations))
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

    private

    def filter(legislations)
      if params[:region].present?
        legislations = legislations.includes(:geography).where(geographies: {region: params[:region]})
      end
      return legislations unless params[:geography]

      legislations.includes(:geography).where(geographies: {id: params[:geography]})
    end
  end
end
