require 'two_factor_authentication/version'
require 'randexp'
require 'devise'
require 'digest'
require 'active_support/concern'

module Devise
  mattr_accessor :login_code_random_pattern
  @@login_code_random_pattern = /\w+/

  mattr_accessor :max_login_attempts
  @@max_login_attempts = 3
end

module TwoFactorAuthentication
  autoload :Schema, 'two_factor_authentication/schema'
  module Controllers
    autoload :Helpers, 'two_factor_authentication/controllers/helpers'
  end
end

Devise.add_module :two_factor_authenticatable, :model => 'two_factor_authentication/models/two_factor_authenticatable', :controller => :two_factor_authentication, :route => :two_factor_authentication

require 'two_factor_authentication/orm/active_record'
require 'two_factor_authentication/routes'
require 'two_factor_authentication/models/two_factor_authenticatable'
require 'two_factor_authentication/rails'
