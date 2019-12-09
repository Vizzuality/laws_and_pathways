module Queries
  module CCLOW
    class LitigationQuery
      attr_accessor :q

      def initialize(params)
        @q = params[:q]
      end

      def call(scope = Litigation.published)
        scope
          .merge(full_text_filter(scope))
      end

      private

      def full_text_filter(scope)
        return scope unless q.present?

        scope.full_text_search(q)
      end
    end
  end
end
