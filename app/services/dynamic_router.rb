class DynamicRouter
  class << self
    def load
      # It will fail if the database does not exist
      if ActiveRecord::Base.connected? && ActiveRecord::Base.connection.table_exists?(:pages)
        LawsAndPathways::Application.routes.draw do
          Page.all.each do |page|
            puts "Routing #{page.slug}"
            get "/tpi/#{page.slug}", to: 'tpi/pages#show', defaults: {id: page.id}
          end
        end
      end
    end

    def reload
      LawsAndPathways::Application.routes_reloader.reload!
    end
  end
end
