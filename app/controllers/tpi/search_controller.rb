module TPI
  class SearchController < TPIController
    def index
      @query = params[:query]

      if @query.present?
        @sectors = TPISector.search(params[:query]).order(:name)
        @companies = TPI::CompanyDecorator.decorate_collection(
          Company.published.search(params[:query]).order(:name)
        )

        publications = Publication.published.search(params[:query]).order(:title)
        news = NewsArticle.published.search(params[:query]).order(:title)
        @publications_and_articles = (publications + news).sort_by(&:title)
      else
        @sectors = @companies = @publications_and_articles = []
      end
    end
  end
end
