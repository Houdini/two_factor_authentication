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
          requirement = rails_version.split('.').length == 2 ? "#{rails_version}.0" : rails_version
          "~> #{requirement}"
        end

gem "rails", rails

# Rails main freezes controller default_url_options; rspec-rails 8.0.4 still
# mutates it in feature specs. Drop once a release includes rspec/rspec-rails#2907.
gem "rspec-rails", github: "rspec/rspec-rails", branch: "main" if rails_version == "main"

ruby_version = Gem::Version.new(RUBY_VERSION)

gem "test-unit", "~> 3.0"

if ruby_version < Gem::Version.new('2.5.0')
  gem 'nokogiri', '~> 1.10.10'
elsif ruby_version < Gem::Version.new('2.6.0')
  gem 'nokogiri', '~> 1.12.5'
end

gem 'loofah', '< 2.21' if ruby_version < Gem::Version.new('2.5.0')
gem 'psych', '< 5' if rails_version == '7.1' && ruby_version < Gem::Version.new('3.0.0')

group :test, :development do
  gem 'ostruct' if ruby_version >= Gem::Version.new('4.0.0')
  case rails_version
  when '5.2', '6.0', '6.1', '7.0'
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
