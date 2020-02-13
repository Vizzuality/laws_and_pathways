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
          .merge(filter_by_instruments)
          .merge(filter_by_governances)
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
        sql = ''

        %w(Response Keyword Framework).each do |type|
          tag_param = type.downcase.pluralize
          next unless params[tag_param.to_sym].present?

          sql += <<-SQL
          INNER JOIN taggings AS #{tag_param}_taggings
          ON #{tag_param}_taggings.taggable_id = legislations.id AND #{tag_param}_taggings.taggable_type = 'Legislation'
            INNER JOIN tags AS #{tag_param} ON #{tag_param}.id = #{tag_param}_taggings.tag_id
            AND #{tag_param}.id IN (#{params[tag_param].join(', ')})
            AND #{tag_param}.type = '#{type}'
          SQL
        end

        sql.present? ? scope.joins(sql) : scope
      end

      def filter_by_instruments
        return scope unless params[:instrument].present?

        scope.joins(:instruments).where(instruments: {id: params[:instrument]})
      end

      def filter_by_governances
        return scope unless params[:governance].present?

        scope.joins(:governances).where(governances: {id: params[:governance]})
      end

      def filter_by_from_date
        return scope unless params[:from_date].present?

        event_ids =
          Event.where(eventable_type: 'Legislation').group('eventable_id', :id).having('MAX(date) >= date').map(&:id)
        scope.joins(:events)
          .where('events.date >= (?) AND events.id in (?)', Date.new(params[:from_date].to_i, 1, 1), event_ids).distinct
      end

      def filter_by_to_date
        return scope unless params[:to_date].present?

        event_ids =
          Event.where(eventable_type: 'Legislation').group('eventable_id', :id).having('MAX(date) >= date').map(&:id)
        scope.joins(:events)
          .where('events.date <= (?) AND events.id in (?)', Date.new(params[:to_date].to_i, 12, 31), event_ids).distinct
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
