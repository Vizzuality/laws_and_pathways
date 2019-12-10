module Queries
  module CCLOW
    class GeographyQuery
      attr_reader :scope, :params

      def initialize(params)
        @params = params
      end

      def call(scope = Geography.published)
        @scope = scope

        scope
          .merge(full_text_filter)
      end

      private

      def full_text_filter
        return scope unless params[:q].present?

        scope.full_text_search(params[:q])
      end
    end
  end
end
