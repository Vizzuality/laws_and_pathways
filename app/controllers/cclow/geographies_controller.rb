module CCLOW
  class GeographiesController < CCLOWController
    include GeographyController
    before_action :redirect_if_numeric_or_historic_slug, only: [:show]

    def show
      fixed_navbar(@geography.name, admin_geography_path(@geography))
    end

    private

    def redirect_if_numeric_or_historic_slug
      redirect_to cclow_geography_path(@geography.slug), status: :moved_permanently if params[:id] != @geography.slug
    end
  end
end
