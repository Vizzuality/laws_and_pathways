require_relative 'boot'

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module LawsAndPathways
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil
    config.active_record.schema_format = :sql

    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    config.cclow_domain = 'cclow.localhost'
    config.tpi_domain = 'tpi.localhost'

    config.csv_options = { entity_sep: ';' }

    config.middleware.insert_before 0, Rack::Cors, debug: !Rails.env.production?,
      logger: (-> { Rails.logger }) do
      allow do
        origins '*'
        resource(
          '*',
          headers: :any,
          methods: [:get, :options],
          max_age: 600
        )
      end
    end
  end

  def self.credentials
    @credentials ||= Rails.application.credentials[Rails.env.to_sym] || {}
  end
end
