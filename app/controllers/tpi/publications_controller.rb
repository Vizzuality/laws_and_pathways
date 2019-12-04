module TPI
  class PublicationsController < TPIController
    def index
      publications = Publication.order(publication_date: :desc)
      news = NewsArticle.order(publication_date: :desc)

      @publications_and_articles = (publications + news)
        .sort { |a, b| b.publication_date <=> a.publication_date }
    end

    def show
      @publication = params[:type].eql?('NewsArticle') ? NewsArticle.find(params[:id]) : Publication.find(params[:id])
      redirect_to '' unless @publication
    end
  end
end
