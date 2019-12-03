module TPI
  class PublicationsController < TPIController
    def index 
      publications = Publication.all.sort_by(&:created_at)
      news = NewsArticle.all.sort_by(&:created_at)

      @publications_and_articles = publications + news
    end

    def show
      @publication = params[:type].eql?("NewsArticle") ? NewsArticle.find(params[:id]) : Publication.find(params[:id])
      redirect_to '' unless @publication
    end
  end
end
