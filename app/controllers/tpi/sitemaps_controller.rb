module TPI
  class SitemapsController < TPIController
    def index
      domain = Rails.configuration.try(:tpi_domain)
      host = domain.start_with?('www.') ? domain : "www.#{domain}"
      @host = "https://#{host}"
    end
  end
end
