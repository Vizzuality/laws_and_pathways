module CCLOW
  module Api
    class SearchController < CCLOWController
      RECENT_DATE = 1.month.ago

      def index
        query = params[:query]

        render json: {
          litigations: Queries::CCLOW::LitigationsSearchQuery.new(query).call,
          legislations: Queries::CCLOW::LegislationsSearchQuery.new(query).call
        }
      end

      def counts
        render json: {
          litigationCount: Litigation.published.size,
          legislationCount: Legislation.published.size,
          targetCount: Target.published.size,
          recentLitigationCount: Litigation.published.where('created_at > ?', RECENT_DATE).size,
          recentLegislationCount: Legislation.published.where('created_at > ?', RECENT_DATE).size,
          recentTargetCount: Target.published.where('created_at > ?', RECENT_DATE).size
        }
      end
    end
  end
end
