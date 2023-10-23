module Queries
  module TPI
    class NewsPublicationsQuery
      include ActiveModel::Model

      attr_reader :publications_scope, :news_scope
      attr_accessor :tags, :sectors, :types

      def call
        (publications + news + insights).uniq.sort_by(&:publication_date).reverse!
      end

      private

      def publications
        return Publication.none if types.present? && !types.include?('Publications')

        filter_scope(Publication.published)
      end

      def news
        return NewsArticle.none if types.present? && !types.include?('News')

        filter_scope(NewsArticle.published.not_insights)
      end

      def insights
        return NewsArticle.none if types.present? && !types.include?('Insights')

        filter_scope(NewsArticle.published.insights)
      end

      def filter_scope(scope)
        scope
          .merge(filter_by_tags(scope))
          .merge(filter_by_sectors(scope))
          .includes([:image_attachment])
          .order(publication_date: :desc)
      end

      def filter_by_tags(scope)
        return scope if tags.blank?

        scope.joins(:keywords).where(tags: {name: tags.split(',').map(&:strip)})
      end

      def filter_by_sectors(scope)
        return scope if sectors.blank?

        scope.joins(:tpi_sectors).where('tpi_sectors.name IN (?)', sectors.split(',').map(&:strip))
      end
    end
  end
end
