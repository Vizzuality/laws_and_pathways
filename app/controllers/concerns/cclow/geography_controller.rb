module CCLOW
  module GeographyController
    extend ActiveSupport::Concern

    included do
      before_action :set_geography, :set_geography_overview, :set_breadcrumb

      layout 'cclow/geography'
    end

    private

    def set_breadcrumb
      @breadcrumb = [
        Site::Breadcrumb.new('Home', cclow_root_path),
        Site::Breadcrumb.new(@geography.name, cclow_geography_path(@geography.slug))
      ]
    end

    def set_geography
      @geography = GeographyDecorator.decorate(::Geography.friendly.find(params[:geography_id] || params[:id]))

      @geography_events = @geography.self_and_related_events
      @geography_events_with_links = @geography_events.map do |e|
        ::Api::Presenters::Event.call(e, :geography)
      end
    end

    def set_geography_overview
      @geography_overview = CCLOW::GeographyOverviewDecorator.new(@geography)
    end
  end
end
