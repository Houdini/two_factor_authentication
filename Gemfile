source "http://rubygems.org"

# Specify your gem's dependencies in devise_ip_filter.gemspec
gemspec

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
        when "master"
          {github: "rails/rails"}
        when "default"
          "~> 4.1"
        else
          "~> #{rails_version}"
        end

gem "rails", rails

group :test do
  gem "sqlite3"
end
