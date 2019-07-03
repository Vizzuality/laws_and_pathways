source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.3'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'

gem 'turbolinks', '~> 5'
gem 'bootsnap', '>= 1.1.0', require: false

gem 'activeadmin'
gem 'activeadmin_addons'
gem 'devise'

gem 'aws-sdk-rails'
gem 'aws-sdk-s3'

gem 'friendly_id'

gem 'simplecov', require: false, group: :test

group :development, :test do
  gem 'dotenv-rails'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-collection_matchers'
  gem 'rspec-rails', '~> 3.8'
end

group :development do
  gem 'annotate'
  gem 'bullet'
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

git 'https://github.com/ClimateWatch-Vizzuality/climate-watch-gems.git' do
  gem 'climate_watch_engine', '~> 1.4.3'
end
