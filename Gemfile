source 'https://rubygems.org'

# Specify your gem's dependencies in devise_ip_filter.gemspec
gemspec

rails_version = ENV["RAILS_VERSION"] || "default"

rails = case rails_version
        when "main"
          {github: "rails/rails", branch: "main"}
        when "default"
          "~> 5.2"
        else
          requirement = rails_version.split('.').length == 2 ? "#{rails_version}.0" : rails_version
          "~> #{requirement}"
        end

gem "rails", rails

ruby_version = Gem::Version.new(RUBY_VERSION)

if ruby_version >= Gem::Version.new('2.2.0')
  gem "test-unit", "~> 3.0"
end

if ruby_version < Gem::Version.new('2.3.0')
  gem 'nokogiri', '~> 1.8.5'
elsif ruby_version < Gem::Version.new('2.5.0')
  gem 'nokogiri', '~> 1.10.10'
elsif ruby_version < Gem::Version.new('2.6.0')
  gem 'nokogiri', '~> 1.12.5'
end

gem 'loofah', '< 2.21' if ruby_version < Gem::Version.new('2.5.0')
gem 'psych', '< 5' if rails_version == '7.1' && ruby_version < Gem::Version.new('3.0.0')

group :test, :development do
  gem 'ostruct' if ruby_version >= Gem::Version.new('4.0.0')
  case rails_version
  when '4.2'
    gem 'sqlite3', '~> 1.3.6'
  when 'default', '5.2', '6.0', '6.1', '7.0'
    gem 'sqlite3', '~> 1.4'
  else
    gem 'sqlite3'
  end
  gem 'sprockets-rails'
end

group :test do
  gem 'rack_session_access'
  gem 'ammeter'
end
