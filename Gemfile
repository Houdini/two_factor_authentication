source 'https://rubygems.org'

# Specify your gem's dependencies in two_factor_authentication.gemspec
gemspec

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
        when "main"
          {github: "rails/rails", branch: "main"}
        when "default"
          "~> 8.1.0"
        else
          "~> #{rails_version}.0"
        end

gem "rails", rails

group :test, :development do
  gem 'sqlite3', '>= 2.1'
  gem 'sprockets-rails'
end

group :test do
  gem 'rack_session_access'
  gem 'ammeter'
end
