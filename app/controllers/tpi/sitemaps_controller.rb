module TPI
  class SitemapsController < TPIController
    def index
      @host = "https://#{request.host_with_port}"
      @sectors = TPISector.tpi_tool.order(:name)
      @companies = Company.published.select(:id, :slug).order(:name)
      @publications = Publication.published.select(:id, :slug)
      @news = NewsArticle.published.select(:id)
      @banks = Bank.all.select(:id, :slug).order(:name)
    end
  end
end
