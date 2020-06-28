module Queries
  module CCLOW
    class LitigationQuery
      include CommonFilters

      attr_reader :scope, :params

      TAG_PARAMS = %w(responses keywords).freeze

      def initialize(params)
        @params = params
      end

      def call(scope = Litigation.published)
        @scope = scope

        @scope
          .merge(full_text_filter)
          .merge(filter_by_geography_or_region)
          .merge(filter_by_tags)
          .merge(filter_by_last_change_from)
          .merge(filter_by_last_change_to)
          .merge(filter_by_case_started_from)
          .merge(filter_by_case_started_to)
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

      private

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

      def filter_by_case_started_from
        return scope unless params[:case_started_from].present?

        scope.started.where('events.date >= (?)', Date.new(params[:case_started_from].to_i, 1, 1))
      end

      def filter_by_case_started_to
        return scope unless params[:case_started_to].present?

        scope.started.where('events.date <= (?)', Date.new(params[:case_started_to].to_i, 12, 31))
      end
    end
  end
end
