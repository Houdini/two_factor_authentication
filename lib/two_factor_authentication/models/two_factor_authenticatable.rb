require 'two_factor_authentication/hooks/two_factor_authenticatable'
require 'rotp'

module Devise
  module Models
    module TwoFactorAuthenticatable
      extend ActiveSupport::Concern

      module ClassMethods
        def has_one_time_password(options = {})

          cattr_accessor :otp_column_name
          self.otp_column_name = "otp_secret_key"

          include InstanceMethodsOnActivation

          before_create { populate_otp_column }

          if respond_to?(:attributes_protected_by_default)
            def self.attributes_protected_by_default #:nodoc:
              super + [self.otp_column_name]
            end
          end
        end
        ::Devise::Models.config(self, :max_login_attempts, :allowed_otp_drift_seconds, :otp_length, :remember_otp_session_for_seconds)
      end

      module InstanceMethodsOnActivation
        def authenticate_otp(code, options = {})
          totp = ROTP::TOTP.new(self.otp_column, { digits: options[:otp_length] || self.class.otp_length })
          drift = options[:drift] || self.class.allowed_otp_drift_seconds

          totp.verify_with_drift(code, drift)
        end

        def otp_code(time = Time.now, options = {})
          ROTP::TOTP.new(self.otp_column, { digits: options[:otp_length] || self.class.otp_length }).at(time, true)
        end

        def provisioning_uri(account = nil, options = {})
          account ||= self.email if self.respond_to?(:email)
          ROTP::TOTP.new(self.otp_column, options).provisioning_uri(account)
        end

        def otp_column
          self.send(self.class.otp_column_name)
        end

        def otp_column=(attr)
          self.send("#{self.class.otp_column_name}=", attr)
        end

        def need_two_factor_authentication?(request)
          true
        end

        def send_two_factor_authentication_code
          raise NotImplementedError.new("No default implementation - please define in your class.")
        end

        def max_login_attempts?
          second_factor_attempts_count.to_i >= max_login_attempts.to_i
        end

        def max_login_attempts
          self.class.max_login_attempts
        end

        def populate_otp_column
          self.otp_column = ROTP::Base32.random_base32
        end

      end
    end
  end
end
