module TPI
  class SitemapsController < TPIController
    def index
      domain = Rails.configuration.try(:tpi_domain)
      host = domain.start_with?('www.') ? domain : "www.#{domain}"
      @host = "https://#{host}"
      @sectors = TPISector.order(:name)
      @companies = Company.published.select(:id, :slug).order(:name)
      @publications = Publication.select(:id)
      @news = NewsArticle.select(:id)
    end
  end
end
