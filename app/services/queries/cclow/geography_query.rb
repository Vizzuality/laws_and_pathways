module Queries
  module CCLOW
    class GeographyQuery
      attr_accessor :q
      attr_reader :scope

      def initialize(params)
        @q = params[:q]
      end

      def call(scope = Geography.published)
        @scope = scope

        scope
          .merge(full_text_filter)
      end

      private

      def full_text_filter
        return scope unless q.present?

        scope.full_text_search(q)
      end
    end
  end
end
