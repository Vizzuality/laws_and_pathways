class DynamicRouter
  class << self
    def load
      unless ActiveRecord::Base.connection.table_exists?(:pages) ||
          (!Rails.env.development && ActiveRecord::Base.connected?)
        return
      end

      LawsAndPathways::Application.routes.draw do
        Page.all.each do |page|
          puts "Routing #{page.slug}"
          get "/tpi/#{page.slug}", to: 'tpi/pages#show', defaults: {id: page.id}
        end
      end
    end

    def reload
      LawsAndPathways::Application.routes_reloader.reload!
    end
  end
end
