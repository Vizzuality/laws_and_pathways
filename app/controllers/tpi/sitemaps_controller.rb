module TPI
  class SitemapsController < TPIController
    def index
      @host = "https://#{request.host_with_port}"
      @sectors = TPISector.tpi_tool.order(:name)
      @companies = Company.published.select(:id, :slug).order(:name)
      @publications = Publication.published.select(:id)
      @news = NewsArticle.published.select(:id)
    end
  end
end
