require 'capybara/rspec'

Capybara.app = Dummy::Application

RSpec.configure do |config|
  config.before(:each, :feature) do

  end
end
