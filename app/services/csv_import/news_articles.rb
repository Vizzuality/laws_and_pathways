module CSVImport
  class NewsArticles < BaseImporter
    include Helpers

    def import
      import_each_csv_row(csv) do |row|
        news_article = prepare_news_article(row)

        news_article.assign_attributes(news_article_attributes(row))

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

    def news_article_attributes(row)
      {
        title: row[:title],
        content: row[:content],
        publication_date: row[:date]
      }
    end
  end
end
