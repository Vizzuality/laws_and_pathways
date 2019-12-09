module Queries
  module CCLOW
    class TargetsFullTextQuery
      def initialize(query)
        @query = query
      end

      def call
        return unless @query.present?

        Target.where(id: target_ids)
      end

      private

      def target_ids
        Target.find_by_sql([full_text_sql, @query + ':*']).pluck(:id)
      end

      def full_text_sql
        <<-SQL
        SELECT tid as id
          FROM (
            SELECT
              t.id as tid,
  		        to_tsvector(t.description) ||
              to_tsvector(t.target_type) ||
  		        to_tsvector(coalesce((string_agg(tag.name, ' ')), '')) as document
            FROM targets t
              LEFT JOIN taggings tg ON tg.taggable_id = t.id AND tg.taggable_type = 'Geography'
              LEFT JOIN tags tag on tag.id = tg.tag_id
            GROUP BY t.id) g_search
          WHERE g_search.document @@ to_tsquery(?)
        SQL
      end
    end
  end
end
