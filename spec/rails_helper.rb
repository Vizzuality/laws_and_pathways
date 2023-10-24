# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
require 'super_diff/rspec-rails'
require 'cancan/matchers'

# workaround to use factory defaults in let_it_be https://github.com/test-prof/test-prof/issues/125#issuecomment-471706752
require 'test_prof/factory_default'
TestProf::FactoryDefault.init
require 'test_prof/recipes/rspec/before_all'
require 'test_prof/recipes/rspec/let_it_be'

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

FactoryBot::SyntaxRunner.class_eval do
  include ActionDispatch::TestProcess
  include ActiveSupport::Testing::FileFixtures
end

# TODO: remove when new capybara and selenium webdriver arrive
# https://github.com/teamcapybara/capybara/issues/2511
Selenium::WebDriver.logger.ignore(:browser_options)

RSpec.configure do |config|
  config.request_snapshots_dir = 'spec/fixtures/snapshots'
  config.request_snapshots_dynamic_attributes = ['Id', 'Country Id']

  config.include FactoryBot::Syntax::Methods
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ControllerHelpers, type: :controller
  # config.include Rails.application.routes.url_helpers, type: :controller
  config.include CapybaraHelpers, type: :system

  config.render_views
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  config.after :each, type: :controller do
    ActiveSupport::CurrentAttributes.reset_all
  end

  config.after do
    # Clear ActiveJob jobs
    if defined?(ActiveJob) && ActiveJob::QueueAdapters::TestAdapter == ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear
      ActiveJob::Base.queue_adapter.performed_jobs.clear
    end
  end

  config.after(:each) do |ex|
    TestProf::FactoryDefault.reset unless ex.metadata[:factory_default] == :keep
  end

  config.after(:all) do
    TestProf::FactoryDefault.reset
  end

  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1400, 800]
  end

  config.before(:each, type: :system, site: 'cclow') do
    Capybara.app_host = "http://#{Rails.configuration.cclow_domain}"
  end

  config.before(:each, type: :system, site: 'tpi') do
    Capybara.app_host = "http://#{Rails.configuration.tpi_domain}"
  end

  config.before(:all, type: :system) do
    require 'rake'
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task['test:db_load'].execute
    # re-attach files for publications and news
    Publication.find_each do |record|
      record.image.attach(
        io: File.open(Rails.root.join("db/seeds/tpi/files/#{record.image.filename}")),
        filename: record.image.filename
      )
      record.file.attach(
        io: File.open(Rails.root.join("db/seeds/tpi/files/#{record.file.filename}")),
        filename: record.file.filename
      )
    end
    NewsArticle.find_each do |record|
      record.image.attach(
        io: File.open(Rails.root.join("db/seeds/tpi/files/#{record.image.filename}")),
        filename: record.image.filename
      )
    end
  end

  config.after(:all, type: :system) do
    DatabaseCleaner.clean_with(:truncation)
  end
end
