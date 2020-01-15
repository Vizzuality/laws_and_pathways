module Queries
  module CCLOW
    # rubocop:disable Metrics/ClassLength
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

      # rubocop:disable Metrics/CyclomaticComplexity
      def filter_by_litigation_sides
        case [params[:side_a].present?, params[:side_b].present?, params[:side_c].present?]
        when [true, false, false]
          filter_by_litigation_side_a
        when [false, true, false]
          filter_by_litigation_side_b
        when [false, false, true]
          filter_by_litigation_side_c
        when [true, true, false]
          filter_by_litigation_side_a_b
        when [true, true, true]
          filter_by_litigation_side_a_b_c
        when [false, true, true]
          filter_by_litigation_side_b_c
        when [true, false, true]
          filter_by_litigation_side_a_c
        else
          scope
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def filter_by_litigation_side_a
        return scope unless params[:side_a].present?

        scope.includes(:litigation_sides)
          .where(litigation_sides: {side_type: 'a', name: params[:side_a]})
      end

      def filter_by_litigation_side_b
        return scope unless params[:side_b].present?

        scope.includes(:litigation_sides)
          .where(litigation_sides: {side_type: 'b', name: params[:side_b]})
      end

      def filter_by_litigation_side_c
        return scope unless params[:side_c].present?

        scope.includes(:litigation_sides)
          .where(litigation_sides: {side_type: 'c', name: params[:side_c]})
      end

      def filter_by_litigation_side_a_b
        return scope unless params[:side_a].present? && params[:side_b].present?

        sql = "
          SELECT side_a.litigation_id
          FROM litigation_sides side_a, litigation_sides side_b
          WHERE side_a.side_type = 'a' AND side_a.name IN (#{params[:side_a].map { |a| "'#{a}'" }.join(', ')})
          AND side_b.side_type = 'b' AND side_b.name IN (#{params[:side_b].map { |b| "'#{b}'" }.join(', ')})
          AND side_a.litigation_id = side_b.litigation_id;
        "

        litigation_resources(sql)
      end

      def filter_by_litigation_side_a_b_c
        return scope unless params[:side_a].present? && params[:side_b].present? && params[:side_c].present?

        sql = "
          SELECT side_a.litigation_id
          FROM litigation_sides side_a, litigation_sides side_b, litigation_sides side_c
          WHERE side_a.side_type = 'a' AND side_a.name IN (#{params[:side_a].map { |a| "'#{a}'" }.join(', ')})
          AND side_b.side_type = 'b' AND side_b.name IN (#{params[:side_b].map { |b| "'#{b}'" }.join(', ')})
          AND side_c.side_type = 'c' AND side_c.name IN (#{params[:side_c].map { |c| "'#{c}'" }.join(', ')})
          AND side_a.litigation_id = side_b.litigation_id
          AND side_a.litigation_id = side_c.litigation_id;
        "

        litigation_resources(sql)
      end

      def filter_by_litigation_side_b_c
        return scope unless params[:side_b].present? && params[:side_c].present?

        sql = "
          SELECT side_b.litigation_id
          FROM litigation_sides side_b, litigation_sides side_c
          WHERE side_b.side_type = 'b' AND side_b.name IN (#{params[:side_b].map { |b| "'#{b}'" }.join(', ')})
          AND side_c.side_type = 'c' AND side_c.name IN (#{params[:side_c].map { |c| "'#{c}'" }.join(', ')})
          AND side_b.litigation_id = side_c.litigation_id;
        "

        litigation_resources(sql)
      end

      def filter_by_litigation_side_a_c
        return scope unless params[:side_a].present? && params[:side_c].present?

        sql = "
          SELECT side_a.litigation_id
          FROM litigation_sides side_a, litigation_sides side_c
          WHERE side_a.side_type = 'a' AND side_a.name IN (#{params[:side_a].map { |a| "'#{a}'" }.join(', ')})
          AND side_c.side_type = 'c' AND side_c.name IN (#{params[:side_c].map { |c| "'#{c}'" }.join(', ')})
          AND side_a.litigation_id = side_c.litigation_id;
        "

        litigation_resources(sql)
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
    # rubocop:enable Metrics/ClassLength
  end
end
