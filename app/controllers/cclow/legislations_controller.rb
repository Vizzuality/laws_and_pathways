module CCLOW
  class LegislationsController < CCLOWController
    include GeographyController

    def index
      @legislations = if show_laws?
                        @geography.legislations.laws
                      else
                        @geography.legislations.policies
                      end
      @legislations = GeographyLegislationDecorator.decorate_collection(@legislations)
    end

    def show
      @legislation = GeographyLegislationDecorator.new(Legislation.find(params[:id]))
    end

    private

    def show_laws?
      params[:scope] == :laws
    end
  end
end
