class DynamicRouter < ApplicationRecord
  def self.load
    LawsAndPathways::Application.routes.draw do
      Page.all.each do |page|
        puts "Routing #{page.slug}"
        get "/tpi/#{page.slug}", :to => "tpi/pages#show", defaults: { id: page.id }
      end
    end
  end

  def self.reload
    LawsAndPathways::Application.routes_reloader.reload!
  end
end
