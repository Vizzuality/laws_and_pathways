Dir[Rails.root.join('lib/extensions/*.rb')].each { |f| require f }
