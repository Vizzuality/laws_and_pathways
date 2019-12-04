module TPI
  class PublicationsController < TPIController
    # rubocop:disable Metrics/AbcSize
    def index
      @tags = (
        NewsArticle.all.map(&:keywords_list).flatten +
        Publication.all.map(&:keywords_list).flatten
      ).uniq
      @sectors = (Publication.joins(:sector).select('tpi_sectors.name as sector_name').map(&:sector_name) +
        NewsArticle.joins(:sector).select('tpi_sectors.name as sector_name').map(&:sector_name)).uniq

      filter_by_tags
      filter_by_sectors

      publications = (@publications_by_tags + @publications_by_sectors).uniq
      news = (@news_by_tags + @news_by_sectors).uniq

      @filters_open = if params[:filtersOpen].present?
                        params[:filtersOpen]
                      else
                        false
                      end

      @publications_and_articles = (publications.uniq + news.uniq)
        .sort { |a, b| b.publication_date <=> a.publication_date }
    end
    # rubocop:enable Metrics/AbcSize

    def show
      @publication = params[:type].eql?('NewsArticle') ? NewsArticle.find(params[:id]) : Publication.find(params[:id])
      redirect_to '' unless @publication
    end

    private

    def filter_by_tags
      if params[:activeTags].present?
        @active_tags = params[:activeTags].tr('[]', '').split(', ')
        @publications_by_tags = Publication.joins(:keywords)
          .where(tags: {name: @active_tags}).order(publication_date: :desc)
        @news_by_tags = NewsArticle.joins(:keywords).where(tags: {name: @active_tags}).order(publication_date: :desc)
      else
        @publications_by_tags = Publication.order(publication_date: :desc)
        @news_by_tags = NewsArticle.order(publication_date: :desc)
        @active_tags = []
      end
    end

    def filter_by_sectors
      if params[:activeSectors].present?
        @active_sectors = params[:activeSectors].tr('[]', '').split(', ')
        @publications_by_sectors = Publication.joins(:sector).where('tpi_sectors.name IN (?)', @active_sectors)
        @news_by_sectors = NewsArticle.joins(:sector).where('tpi_sectors.name IN (?)', @active_sectors)
      else
        @publications_by_sectors = Publication.order(publication_date: :desc)
        @news_by_sectors = NewsArticle.order(publication_date: :desc)
        @active_sectors = []
      end
    end
  end
end
