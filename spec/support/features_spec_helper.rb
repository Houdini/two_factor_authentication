require 'warden'

module FeaturesSpecHelper
  def warden
    request.env['warden']
  end
end

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :feature
  config.include FeaturesSpecHelper, type: :feature
end

