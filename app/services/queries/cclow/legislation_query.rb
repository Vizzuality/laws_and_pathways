module Queries
  module CCLOW
    class LegislationQuery
      attr_accessor :q, :region, :from_date
      attr_reader :scope

      def initialize(params)
        @q = params[:q]
        @region = params[:region]
        @from_date = params[:fromDate]
      end

      def call(scope = Legislation.published)
        @scope = scope

        @scope
          .merge(full_text_filter)
          .merge(filter_by_region)
          .merge(filter_by_from_date)
      end

      private

      def full_text_filter
        return scope unless q.present?

        scope.full_text_search(q)
      end

      def filter_by_region
        return scope unless region.present?

        scope.includes(:geography).where(geographies: {region: region})
      end

      def filter_by_from_date
        return scope unless from_date.present?

        scope.where('updated_at >= ?', from_date)
      end
    end
  end
end
