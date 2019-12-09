module CCLOW
  module Api
    class SearchController < CCLOWController
      RECENT_DATE = 1.month.ago

      def index
        query = params[:q]

        return render json: {} unless query.present?

        render json: {
          litigationCount: Litigation.published.full_text_search(query).size,
          legislationCount: Legislation.published.full_text_search(query).size,
          targetCount: Target.published.full_text_search(query).size,
          geographies: ::Geography.published.full_text_search(query).select(:id, :name, :slug, :geography_type, :iso)
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
