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

# Rails main freezes controller default_url_options; rspec-rails 8.0.4 still
# mutates it in feature specs. Drop once a release includes rspec/rspec-rails#2907.
gem "rspec-rails", github: "rspec/rspec-rails", branch: "main" if rails_version == "main"

group :test, :development do
  gem 'sqlite3', '>= 2.1'
  gem 'sprockets-rails'
end

group :test do
  gem 'rack_session_access'
  gem 'ammeter'
end
