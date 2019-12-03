source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'
gem 'mini_magick'

gem 'turbolinks', '~> 5'
gem 'bootsnap', '>= 1.4.2', require: false

gem 'activeadmin'
gem 'activeadmin_addons'
gem 'devise', '>= 4.7.1'
gem 'cancancan'
gem 'draper'

gem 'octokit', '~> 4.0'

gem 'google-cloud-storage', require: false

gem 'discard'
gem 'public_activity'
gem 'friendly_id'
gem 'language_list'

gem 'simplecov', require: false, group: :test
gem 'dotenv-rails'

gem 'active_link_to' # simple helper for making links with active class
gem 'font-awesome-rails'

# TPI
gem 'chartkick'
gem 'react-rails'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails', '~> 3.8'
  gem 'timecop'
end

group :development do
  gem 'countries' # just to generate country flags using rake task flags:generate
  gem 'annotate'
  gem 'bullet'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'capistrano', '~> 3.11', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-passenger'
  gem 'capistrano-yarn'
  gem 'capistrano-nvm'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
