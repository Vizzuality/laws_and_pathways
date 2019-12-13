module Queries
  module CCLOW
    class TargetQuery
      attr_reader :scope, :params

      def initialize(params)
        @params = params
      end

      def call(scope = Target.published)
        @scope = scope

        scope
          .merge(full_text_filter)
          .merge(filter_by_region)
          .merge(filter_by_tags)
          .merge(filter_recent)
      end

      private

      def full_text_filter
        return scope unless params[:q].present?

        scope.full_text_search(params[:q])
      end

      def filter_by_region
        return scope unless params[:region].present?

        scope.includes(:geography).where(geographies: {region: params[:region]})
      end

      def filter_by_tags
        return scope unless params[:tags].present?

        scope.includes(:tags).where(tags: {id: params[:tags]})
      end

      def filter_recent
        return scope unless params[:recent].present?

        scope.recent
      end
    end
  end
end
