module CCLOW
  module Api
    class SearchController < CCLOWController
      RECENT_DATE = 1.month.ago

      def index
        query = params[:q]

        return render json: {} unless query.present?

        render json: {
          litigationCount: Queries::CCLOW::LitigationQuery.new(params).call.size,
          legislationCount: Queries::CCLOW::LegislationQuery.new(params).call.size,
          targetCount: Queries::CCLOW::TargetQuery.new(params).call.size,
          geographies: Queries::CCLOW::GeographyQuery.new(params).call.select(:id, :name, :slug, :geography_type, :iso)
        }
      end

      def counts
        render json: {
          geographies: ::Geography.published.select(:id, :name, :slug, :geography_type, :iso).first(3),
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
