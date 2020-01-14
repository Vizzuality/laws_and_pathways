module CCLOW
  module Geography
    class LitigationCasesController < CCLOWController
      include GeographyController

      def index
        add_breadcrumb('Litigation cases', request.path)
        @litigations = @geography.litigations.published.includes(:events)
        @litigations = CCLOW::LitigationDecorator.decorate_collection(@litigations)
      end

      # rubocop:disable Metrics/AbcSize
      def show
        @litigation = Litigation.find(params[:id])
        @legislations = CCLOW::LegislationDecorator.decorate_collection(@litigation.legislations)
        add_breadcrumb('Litigation cases', cclow_geography_litigation_cases_path(@geography))
        add_breadcrumb(@litigation.title, request.path)
        @sectors = @litigation.laws_sectors.order(:name)
        @keywords = @litigation.keywords.order(:name)
        @responses = @litigation.responses.order(:name)
        @jurisdiction = @litigation.jurisdiction
        @party_types = @litigation.litigation_sides&.pluck(:party_type)
        @sides_a = @litigation.litigation_sides.where(litigation_sides: {side_type: 'a'}).pluck(:name)
        @sides_b = @litigation.litigation_sides.where(litigation_sides: {side_type: 'b'}).pluck(:name)
        @sides_c = @litigation.litigation_sides.where(litigation_sides: {side_type: 'c'}).pluck(:name)
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
