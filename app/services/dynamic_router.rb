class DynamicRouter
  class << self
    def load
      return unless ActiveRecord::Base.connection.table_exists?('pages')

      LawsAndPathways::Application.routes.draw do
        TPIPage.all.each do |page|
          get "/#{page.slug}",
              to: 'tpi/pages#show',
              defaults: {id: page.id},
              constraints: DomainConstraint.new(Rails.configuration.tpi_domain)
        end
        CCLOWPage.all.each do |page|
          get "/#{page.slug}",
              to: 'cclow/pages#show',
              defaults: {id: page.id},
              constraints: DomainConstraint.new(Rails.configuration.cclow_domain)
        end
      end
    rescue PG::ConnectionBad, ActiveRecord::NoDatabaseError
      puts $ERROR_INFO
      puts 'No database or connection failed. Skipping DynamicRoutes load'
    end

    def reload
      LawsAndPathways::Application.routes_reloader.reload!
    end
  end
end
