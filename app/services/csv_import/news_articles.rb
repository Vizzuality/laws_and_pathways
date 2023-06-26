module CSVImport
  class NewsArticles < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        news_article = prepare_news_article(row)

        news_article.title = row[:title] if row.header?(:title)
        news_article.content = row[:content] if row.header?(:content)
        news_article.publication_date = row[:publication_date] if row.header?(:publication_date)
        news_article.keywords = parse_tags(row[:keywords], keywords) if row.header?(:keywords)
        news_article.tpi_sectors = find_or_create_tpi_sectors(row[:sectors], categories: [Company]) if row.header?(:sectors)

        was_new_record = news_article.new_record?
        any_changes = news_article.changed?

        news_article.save!

        update_import_results(was_new_record, any_changes)
      end
    end

    private

    def resource_klass
      NewsArticle
    end

    def prepare_news_article(row)
      find_record_by(:id, row) ||
        find_record_by(:title, row) ||
        resource_klass.new
    end
  end
end
