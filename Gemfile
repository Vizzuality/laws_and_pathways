source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

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

gem 'activeadmin'
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
gem 'pg_search'

gem 'simplecov', require: false, group: :test
gem 'dotenv-rails'

gem 'active_link_to' # simple helper for making links with active class
gem 'font-awesome-rails'

# TPI
gem 'chartkick'
gem 'react-rails'

gem 'appsignal'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'database_cleaner-active_record'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails', '~> 3.8'
  gem 'timecop'
  gem 'pry'
end

group :development do
  gem 'annotate'
  gem 'brakeman', require: false
  gem 'bundler-audit', require: false
  gem 'bullet'
  gem 'capistrano', '~> 3.11', require: false
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
