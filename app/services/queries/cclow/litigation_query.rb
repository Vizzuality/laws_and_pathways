module Queries
  module CCLOW
    class LitigationQuery
      attr_reader :scope, :params

      TAG_PARAMS = %w(responses keywords).freeze

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
          .merge(filter_by_sector)
          .merge(filter_recent)
          .merge(order)
          .distinct
      end
      # rubocop:enable Metrics/AbcSize

      private

      def full_text_filter
        return scope unless params[:q].present?

        scope.full_text_search(params[:q]).with_pg_search_rank
      end

      def filter_by_region
        return scope unless params[:region].present?

        scope.includes(:geography).where(geographies: {region: params[:region]})
      end

      def filter_by_sector
        return scope unless params[:law_sector].present?

        scope.joins(:laws_sectors).where(laws_sectors: {id: params[:law_sector]})
      end

      def filter_by_geography
        return scope unless params[:geography].present?

        scope.where(geography_id: params[:geography])
      end

      def filter_by_tags
        return scope unless TAG_PARAMS.any? { |p| params[p.to_sym].present? }

        tag_ids = TAG_PARAMS.flat_map { |p| params[p.to_sym] }.compact
        scope.where(id: Litigation.with_tags_by_id(tag_ids))
      end

      def filter_by_from_date
        return scope unless params[:from_date].present?

        scope.with_last_events.where('last_events.date >= (?)', Date.new(params[:from_date].to_i, 1, 1))
      end

      def filter_by_to_date
        return scope unless params[:to_date].present?

        scope.with_last_events.where('last_events.date <= (?)', Date.new(params[:to_date].to_i, 12, 31))
      end

      def filter_by_to_status
        return scope unless params[:status].present?

        scope.with_last_events.where(last_events: {event_type: params[:status]})
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

        scope
          .includes(:litigation_sides)
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
        return scope if params[:q].present?

        scope
          .with_last_events
          .order('last_events.date DESC NULLS LAST, litigations.id')
          .select('last_events.date, litigations.*')
      end
    end
  end
end
