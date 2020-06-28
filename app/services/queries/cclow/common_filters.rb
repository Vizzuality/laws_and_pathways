module Queries
  module CCLOW
    module CommonFilters
      def full_text_filter
        return scope unless params[:q].present?

        scope.full_text_search(params[:q]).with_pg_search_rank
      end

      def filter_by_region
        return scope unless params[:region].present?

        # to be able to use 'or'
        ids = scope.joins(:geography).where(geographies: {region: params[:region]}).pluck(:id)
        scope.where(id: ids)
      end

      def filter_by_sector
        return scope unless params[:law_sector].present?

        scope.joins(:laws_sectors).where(laws_sectors: {id: params[:law_sector]})
      end

      def filter_by_geography
        return scope unless params[:geography].present?

        scope.where(geography_id: params[:geography])
      end

      def filter_by_geography_or_region
        return filter_by_geography if params[:geography].present? && params[:region].nil?
        return filter_by_region if params[:region].present? && params[:geography].nil?

        filter_by_geography.or(filter_by_region)
      end

      def filter_by_tags
        return scope unless tag_params.any? { |p| params[p.to_sym].present? }

        tag_ids = tag_params.flat_map { |p| params[p.to_sym] }.compact
        scope.where(id: scope.unscoped.with_tags_by_id(tag_ids))
      end

      def filter_by_last_change_from
        return scope unless params[:last_change_from].present?

        scope.with_last_events.where('last_events.date >= (?)', Date.new(params[:last_change_from].to_i, 1, 1))
      end

      def filter_by_last_change_to
        return scope unless params[:last_change_to].present?

        scope.with_last_events.where('last_events.date <= (?)', Date.new(params[:last_change_to].to_i, 12, 31))
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
