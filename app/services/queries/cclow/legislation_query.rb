module Queries
  module CCLOW
    class LegislationQuery
      include CommonFilters

      attr_reader :scope, :params

      TAG_PARAMS = %w(responses keywords frameworks).freeze

      def initialize(params)
        @params = params
      end

      def call(scope = Legislation.published)
        @scope = scope

        @scope
          .merge(full_text_filter)
          .merge(filter_by_region)
          .merge(filter_by_geography)
          .merge(filter_by_tags)
          .merge(filter_by_instruments)
          .merge(filter_by_governances)
          .merge(filter_by_from_date)
          .merge(filter_by_to_date)
          .merge(filter_by_type)
          .merge(filter_recent)
          .merge(filter_by_sector)
          .merge(order)
          .distinct
      end

      private

      def filter_by_instruments
        return scope unless params[:instrument].present?

        scope.joins(:instruments).where(instruments: {id: params[:instrument]})
      end

      def filter_by_governances
        return scope unless params[:governance].present?

        scope.joins(:governances).where(governances: {id: params[:governance]})
      end

      def filter_by_type
        return scope unless params[:type].present?

        scope.where(legislation_type: params[:type])
      end
    end
  end
end
