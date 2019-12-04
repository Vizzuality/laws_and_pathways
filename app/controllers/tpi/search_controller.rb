module TPI
  class SearchController < TPIController
    def index
      @sectors = TPISector.search(params[:query]).order(:name)
      @companies = Company.search(params[:query]).order(:name)
      publications = Publication.search(params[:query]).order(:title)
      news = NewsArticle.search(params[:query]).order(:title)
      @publications_and_articles = (publications + news)
        .sort { |a, b| a.title <=> b.title }
    end
  end
end
