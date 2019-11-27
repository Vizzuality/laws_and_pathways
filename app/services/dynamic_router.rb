class DynamicRouter
  class << self
    def load
      return unless ActiveRecord::Base.connection.table_exists?('pages')
      LawsAndPathways::Application.routes.draw do
        Page.all.each do |page|
          get "/tpi/#{page.slug}", to: 'tpi/pages#show', defaults: {id: page.id}
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
