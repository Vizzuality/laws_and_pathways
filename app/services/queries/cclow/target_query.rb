module Queries
  module CCLOW
    class TargetQuery
      attr_accessor :q, :region
      attr_reader :scope

      def initialize(params)
        @q = params[:q]
        @region = params[:region]
      end

      def call(scope = Target.published)
        @scope = scope

        scope
          .merge(full_text_filter)
          .merge(filter_by_region)
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
    end
  end
end
