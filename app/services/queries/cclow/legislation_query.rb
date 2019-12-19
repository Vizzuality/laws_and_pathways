module Queries
  module CCLOW
    class LegislationQuery
      attr_reader :scope, :params

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
          .merge(filter_by_from_date)
          .merge(filter_by_to_date)
          .merge(filter_by_type)
          .merge(filter_recent)
      end

      private

      def full_text_filter
        return scope unless params[:q].present?

        scope.where(id: scope.full_text_search(params[:q]).pluck(:id))
      end

      def filter_by_geography
        return scope unless params[:geography].present?

        scope.where(geography_id: params[:geography])
      end

      def filter_by_region
        return scope unless params[:region].present?

        scope.includes(:geography).where(geographies: {region: params[:region]})
      end

      def filter_by_tags
        return scope unless params[:tags].present?

        scope.includes(:tags).where(tags: {id: params[:tags]})
      end

      def filter_by_from_date
        return scope unless params[:from_date].present?

        event_ids =
          Event.where(eventable_type: 'Legislation').group('eventable_id', :id).having('MAX(date) >= date').map(&:id)
        scope.joins(:events)
          .where('events.date >= (?) AND events.id in (?)', Date.new(params[:from_date].to_i, 1, 1), event_ids)
      end

      def filter_by_to_date
        return scope unless params[:to_date].present?

        event_ids =
          Event.where(eventable_type: 'Legislation').group('eventable_id', :id).having('MAX(date) >= date').map(&:id)
        scope.joins(:events)
          .where('events.date <= (?) AND events.id in (?)', Date.new(params[:to_date].to_i, 12, 31), event_ids)
      end

      def filter_by_type
        return scope unless params[:type].present?

        scope.where(legislation_type: params[:type])
      end

      def filter_recent
        return scope unless params[:recent].present?

        scope.recent
      end
    end
  end
end
