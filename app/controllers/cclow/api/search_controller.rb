module CCLOW
  module Api
    class SearchController < CCLOWController
      def index
        query = params[:query]

        render json: {
          litigations: Queries::CCLOW::LitigationsSearchQuery.new(query).call,
          legislations: Queries::CCLOW::LegislationsSearchQuery.new(query).call
        }
      end
    end
  end
end
