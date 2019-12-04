module TPI
  class SearchController < TPIController

    def index
      @sectors = TPISector.search(params[:query])
      @companies = Company.search(params[:query])
      publications = Publication.search(params[:query])
      news_articles = Publication.search(params[:query])
    end
  end
end
