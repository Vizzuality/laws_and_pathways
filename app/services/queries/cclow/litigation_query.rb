module Queries
  module CCLOW
    class LitigationQuery
      attr_reader :scope, :params

      def initialize(params)
        @params = params
      end

      # rubocop:disable Metrics/AbcSize
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
          .merge(filter_by_litigation_side_party_types)
          .merge(filter_by_litigation_party_type)
          .merge(filter_by_jurisdiction)
          .merge(filter_recent)
          .merge(order)
      end
      # rubocop:enable Metrics/AbcSize

      private

      def full_text_filter
        return scope unless params[:q].present?

        @full_text_result_ids = scope.full_text_search(params[:q]).pluck(:id)
        scope.where(id: @full_text_result_ids)
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
        sql = ''

        %w(Response Keyword).each do |type|
          tag_param = type.downcase.pluralize
          next unless params[tag_param.to_sym].present?

          sql += <<-SQL
          INNER JOIN taggings AS #{tag_param}_taggings
          ON #{tag_param}_taggings.taggable_id = litigations.id AND #{tag_param}_taggings.taggable_type = 'Litigation'
            INNER JOIN tags AS #{tag_param} ON #{tag_param}.id = #{tag_param}_taggings.tag_id
            AND #{tag_param}.id IN (#{params[tag_param].join(', ')})
            AND #{tag_param}.type = '#{type}'
          SQL
        end

        sql.present? ? scope.joins(sql) : scope
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

      def filter_by_litigation_side_party_types
        sql = ''

        [:a_party_type, :b_party_type, :c_party_type].each do |side_type|
          next unless params[side_type].present?

          sql += <<-SQL
            INNER JOIN litigation_sides AS #{side_type}
            ON #{side_type}.litigation_id = litigations.id AND #{side_type}.side_type = '#{side_type.to_s.split('_')[0]}'
            AND #{side_type}.party_type IN (#{params[side_type].map { |party_type| "'#{party_type}'" }.join(', ')})
          SQL
        end

        sql.present? ? scope.joins(sql) : scope
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

      def order
        return scope.with_id_order(@full_text_result_ids) if defined?(@full_text_result_ids)

        scope.includes(:events).order('events.date DESC NULLS LAST')
      end
    end
  end
end
