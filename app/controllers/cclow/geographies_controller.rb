module CCLOW
  class GeographiesController < CCLOWController
    include GeographyController

    def show
      @admin_panel_section_title = @geography.name
      @link = admin_geography_path(@geography)
    end
  end
end
