module CCLOW
  class GeographiesController < CCLOWController
    include GeographyController

    def show
      fixed_navbar(@geography.name, admin_geography_path(@geography))
    end
  end
end
