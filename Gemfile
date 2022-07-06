source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'
gem 'sass-rails', '>= 6'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'
gem 'image_processing'
gem 'rubyzip'

gem 'turbolinks', '~> 5'
gem 'bootsnap', '>= 1.4.2', require: false

gem 'activerecord-import'
gem 'acts_as_list'
gem 'activeadmin', '2.9.0' # TODO: update when csv export is fixed, check bom options
gem 'activeadmin_addons'
gem 'devise', '>= 4.7.1'
gem 'cancancan'
gem 'draper-cancancan'
gem 'draper'

gem 'octokit', '~> 4.15.0'

gem 'google-cloud-storage', require: false

gem 'discard'
gem 'public_activity'
gem 'friendly_id'
gem 'language_list'
gem 'pg_search', '2.3.2' # TODO: wait until this issue https://github.com/Casecommons/pg_search/issues/446 is resolved

gem 'simplecov', require: false, group: :test
gem 'dotenv-rails'

gem 'active_link_to' # simple helper for making links with active class
gem 'font-awesome-rails'

gem 'react-rails'

gem 'appsignal'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'timecop'
  gem 'pry'
end

group :test do
  gem 'capybara'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails', '~> 4.1.0'
  gem 'rspec-retry'
  gem 'rspec-request_snapshot'
  gem 'selenium-webdriver'
  gem 'super_diff'
  gem 'test-prof'
  gem 'webdrivers', '~> 4.0'
end

group :development do
  gem 'annotate'
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'bullet'
  gem 'capistrano', '~> 3.12', require: false
  gem 'capistrano-bundler'
  gem 'capistrano-nvm'
  gem 'capistrano-passenger'
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-rvm'
  gem 'capistrano-yarn'
  gem 'countries' # just to generate country flags using rake task flags:generate
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'rack-cors'
