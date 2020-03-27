module Queries
  module CCLOW
    class TargetQuery
      include CommonFilters

      attr_reader :scope, :params

      def initialize(params)
        @params = params
      end

      def call(scope = Target.published)
        @scope = scope

        scope
          .merge(full_text_filter)
          .merge(filter_by_region)
          .merge(filter_by_geography)
          .merge(filter_by_target_sector)
          .merge(filter_by_from_date)
          .merge(filter_by_to_date)
          .merge(filter_by_to_type)
          .merge(filter_recent)
          .merge(order)
          .distinct
      end

      private

      def filter_by_to_type
        return scope unless params[:type].present?

        scope.where(target_type: params[:type])
      end

      def filter_by_target_sector
        return scope unless params[:law_sector].present?

        scope.joins(:sector).where(laws_sectors: {id: params[:law_sector]})
      end
    end
  end
end
