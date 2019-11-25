class DynamicRouter
  class << self
    def load
      begin
        # It will fail if the database does not exist
        ActiveRecord::Base.connection
      rescue
        exit 1
      else
        LawsAndPathways::Application.routes.draw do
          Page.all.each do |page|
            puts "Routing #{page.slug}"
            get "/tpi/#{page.slug}", :to => "tpi/pages#show", defaults: { id: page.id }
          end
        end
      end
    end

    def reload
      LawsAndPathways::Application.routes_reloader.reload!
    end
  end
end

