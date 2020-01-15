module Queries
  module CCLOW
    class LitigationQuery
      attr_reader :scope, :params

      def initialize(params)
        @params = params
      end

      def call(scope = Litigation.published)
        @scope = scope

        @scope
          .merge(full_text_filter)
          .merge(filter_by_region)
          .merge(filter_by_geography)
          .merge(filter_by_tags)
          .merge(filter_by_from_date)
          .merge(filter_by_to_date)
          .merge(filter_by_to_status)
          .merge(filter_by_litigation_sides)
          .merge(filter_by_litigation_party_type)
          .merge(filter_by_jurisdiction)
          .merge(filter_recent)
      end

      private

      def full_text_filter
        return scope unless params[:q].present?

        scope.where(id: scope.full_text_search(params[:q]).pluck(:id))
      end

      def filter_by_region
        return scope unless params[:region].present?

        scope.includes(:geography).where(geographies: {region: params[:region]})
      end

      def filter_by_geography
        return scope unless params[:geography].present?

        scope.where(geography_id: params[:geography])
      end

      def filter_by_tags
        return scope unless params[:tags].present?

        scope.includes(:tags).where(tags: {id: params[:tags]})
      end

      def filter_by_from_date
        return scope unless params[:from_date].present?

        event_ids =
          Event.where(eventable_type: 'Litigation').group('eventable_id', :id).having('MAX(date) >= date').map(&:id)

        scope.joins(:events)
          .where('events.date >= (?) AND events.id in (?)', Date.new(params[:from_date].to_i, 1, 1), event_ids).distinct
      end

      def filter_by_to_date
        return scope unless params[:to_date].present?

        event_ids =
          Event.where(eventable_type: 'Litigation').group('eventable_id', :id).having('MAX(date) >= date').map(&:id)
        scope.joins(:events)
          .where('events.date <= (?) AND events.id in (?)', Date.new(params[:to_date].to_i, 12, 31), event_ids)
      end

      def filter_by_to_status
        return scope unless params[:status].present?

        event_ids =
          Event.where(eventable_type: 'Litigation').group('eventable_id', :id).having('MAX(date) >= date').map(&:id)
        scope.joins(:events).where(events: {id: event_ids, event_type: params[:status]}).distinct
      end

      def filter_by_litigation_sides
        sql = ''

        [:side_a, :side_b, :side_c].each do |side|
          next unless params[side].present?

          sql += <<-SQL
            INNER JOIN litigation_sides AS #{side}
            ON #{side}.litigation_id = litigations.id AND #{side}.side_type = '#{side.to_s.split('_')[1]}'
            AND #{side}.name IN (#{params[side].map { |a| "'#{a}'" }.join(', ')})
          SQL
        end

        sql.present? ? scope.joins(sql) : scope
      end

      def filter_by_litigation_party_type
        return scope unless params[:party_type].present?

        scope.includes(:litigation_sides)
          .where(litigation_sides: {party_type: params[:party_type]})
      end

      def filter_by_jurisdiction
        return scope unless params[:jurisdiction].present?

        scope.where(jurisdiction: params[:jurisdiction])
      end

      def filter_recent
        return scope unless params[:recent].present?

        scope.recent
      end

      def litigation_resources(sql)
        ids = ActiveRecord::Base.connection.execute(sql).map { |row| row['litigation_id'] }
        Litigation.where(id: ids)
      end
    end
  end
end
