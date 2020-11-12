module TPI
  class SitemapsController < TPIController
    def index
      @host = "https://#{request.host_with_port}"
      @sectors = TPISector.order(:name)
      @companies = Company.published.select(:id, :slug).order(:name)
      @publications = Publication.select(:id)
      @news = NewsArticle.select(:id)
    end
  end
end
