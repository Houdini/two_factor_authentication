source 'https://rubygems.org'

# Specify your gem's dependencies in devise_ip_filter.gemspec
gemspec

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
        when "master"
          {github: "rails/rails"}
        when "default"
          "~> 5.2"
        else
          "~> #{rails_version}"
        end

gem "rails", rails

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('2.2.0')
  gem "test-unit", "~> 3.0"
end
gem 'sprockets-rails', '~> 2.0'
group :test, :development do
  gem 'sqlite3'
end

group :test do
  gem 'rack_session_access'
  gem 'ammeter'
end
