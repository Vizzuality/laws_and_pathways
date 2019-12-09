module Queries
  module CCLOW
    class LitigationsFullTextQuery
      def initialize(query)
        @query = query
      end

      def call
        return unless @query.present?

        Litigation.where(id: litigation_ids)
      end

      private

      def litigation_ids
        Litigation.find_by_sql([full_text_sql, @query + ':*']).pluck(:id)
      end

      def full_text_sql
        <<-SQL
        SELECT lid as id
          FROM (
            SELECT
              l.id as lid,
  		        to_tsvector(l.title) ||
  		        to_tsvector(l.summary) ||
  		        to_tsvector(coalesce((string_agg(tag.name, ' ')), '')) as document
            FROM litigations l
              LEFT JOIN taggings tg ON tg.taggable_id = l.id AND tg.taggable_type = 'Litigation'
              LEFT JOIN tags tag on tag.id = tg.tag_id
            GROUP BY l.id) l_search
          WHERE l_search.document @@ to_tsquery(?)
        SQL
      end
    end
  end
end
