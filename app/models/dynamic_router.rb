class DynamicRouter < ApplicationRecord
  def self.load
    Rails.application.routes.draw do
      Page.all.each do |page|
        puts "Routing #{page.slug}"
        get "/tpi/#{page.slug}", :to => "tpi/pages#show", defaults: { id: page.id }
      end
    end
  end

  def self.reload
    Rails.application.routes_reloader.reload!
  end
end
