module Queries
  module CCLOW
    class GeographiesFullTextQuery
      def initialize(query)
        @query = query
      end

      def call
        return unless @query.present?

        Geography.where(id: geography_ids)
      end

      private

      def geography_ids
        Geography.find_by_sql([full_text_sql, {query: @query + ':*'}])
      end

      def full_text_sql
        <<-SQL
        SELECT gid as id
          FROM (
            SELECT
              g.id as gid,
  		        setweight(to_tsvector(g.name), 'A') ||
              setweight(to_tsvector(g.region), 'B') ||
              setweight(to_tsvector(coalesce((string_agg(tag.name, ' ')), '')), 'C') ||
  		        setweight(to_tsvector(g.legislative_process), 'D') as document
            FROM geographies g
              LEFT JOIN taggings tg ON tg.taggable_id = g.id AND tg.taggable_type = 'Geography'
              LEFT JOIN tags tag on tag.id = tg.tag_id
            GROUP BY g.id) g_search
          WHERE g_search.document @@ to_tsquery(:query)
        SQL
      end
    end
  end
end
