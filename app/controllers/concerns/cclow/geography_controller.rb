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
        Site::Breadcrumb.new(@geography.name, cclow_geography_path(@geography))
      ]
    end

    def set_geography
      @geography = Geography.find(params[:geography_id] || params[:id])
    end

    def set_geography_overview
      @geography_overview = GeographyOverviewDecorator.new(@geography)
    end
  end
end
