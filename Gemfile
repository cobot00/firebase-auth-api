source 'https://rubygems.org'
ruby '2.5.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.7'
gem 'bootsnap', '1.3.0'
gem 'activestorage', '~> 5.2.0'

gem 'jwt', '2.1.0'
gem 'firebase-auth', '0.1.4'

group :development, :test do
  gem 'rubocop', '0.53.0', require: false
  gem 'rspec-rails', '~> 3.7'
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails', '~> 4.10.0'
  gem 'pry-rails', '~> 0.3.6'
  gem 'pry-byebug', '~> 3.6.0'
end

group :development do
end

group :test do
  gem 'timecop', '0.9.1'
  gem 'database_cleaner', '~> 1.7.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
