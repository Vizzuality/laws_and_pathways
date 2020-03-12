module Queries
  module CCLOW
    module CommonFilters
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
        return scope unless tag_params.any? { |p| params[p.to_sym].present? }

        tag_ids = tag_params.flat_map { |p| params[p.to_sym] }.compact
        scope.where(id: scope.unscoped.with_tags_by_id(tag_ids))
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

      def filter_recent
        return scope unless params[:recent].present?

        scope.recent
      end

      def order
        return scope if params[:q].present?

        scope
          .with_last_events
          .order("last_events.date DESC NULLS LAST, #{scope.table_name}.id")
          .select("last_events.date, #{scope.table_name}.*")
      end

      def tag_params
        self.class.const_get(:TAG_PARAMS)
      end
    end
  end
end
