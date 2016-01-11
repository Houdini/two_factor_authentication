require 'two_factor_authentication/hooks/two_factor_authenticatable'
require 'rotp'
require 'encryptor'

module Devise
  module Models
    module TwoFactorAuthenticatable
      extend ActiveSupport::Concern

      module ClassMethods
        def has_one_time_password(options = {})
          include InstanceMethodsOnActivation
          include EncryptionInstanceMethods if options[:encrypted] == true

          before_create { populate_otp_column }
        end

        ::Devise::Models.config(
          self, :max_login_attempts, :allowed_otp_drift_seconds, :otp_length,
          :remember_otp_session_for_seconds, :otp_secret_encryption_key)
      end

      module InstanceMethodsOnActivation
        def authenticate_otp(code, options = {})
          totp = ROTP::TOTP.new(
            otp_secret_key, digits: options[:otp_length] || self.class.otp_length
          )
          drift = options[:drift] || self.class.allowed_otp_drift_seconds

          totp.verify_with_drift(code, drift)
        end

        def otp_code(time = Time.now, options = {})
          ROTP::TOTP.new(
            otp_secret_key,
            digits: options[:otp_length] || self.class.otp_length
          ).at(time, true)
        end

        def provisioning_uri(account = nil, options = {})
          account ||= self.email if self.respond_to?(:email)
          ROTP::TOTP.new(otp_secret_key, options).provisioning_uri(account)
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
          self.otp_secret_key = ROTP::Base32.random_base32
        end
      end

      module EncryptionInstanceMethods
        def otp_secret_key
          decrypt(encrypted_otp_secret_key)
        end

        def otp_secret_key=(value)
          self.encrypted_otp_secret_key = encrypt(value)
        end

        private

        def decrypt(encrypted_value)
          return encrypted_value if encrypted_value.blank?

          encrypted_value = encrypted_value.unpack('m').first

          value = ::Encryptor.decrypt(encryption_options_for(encrypted_value))

          if defined?(Encoding)
            encoding = Encoding.default_internal || Encoding.default_external
            value = value.force_encoding(encoding.name)
          end

          value
        end

        def encrypt(value)
          return value if value.blank?

          value = value.to_s
          encrypted_value = ::Encryptor.encrypt(encryption_options_for(value))

          encrypted_value = [encrypted_value].pack('m')

          encrypted_value
        end

        def encryption_options_for(value)
          {
            value: value,
            key: Devise.otp_secret_encryption_key,
            iv: iv_for_attribute,
            salt: salt_for_attribute
          }
        end

        def iv_for_attribute(algorithm = 'aes-256-cbc')
          iv = encrypted_otp_secret_key_iv

          if iv.nil?
            algo = OpenSSL::Cipher::Cipher.new(algorithm)
            iv = [algo.random_iv].pack('m')
            self.encrypted_otp_secret_key_iv = iv
          end

          iv.unpack('m').first if iv.present?
        end

        def salt_for_attribute
          salt = encrypted_otp_secret_key_salt ||
                 self.encrypted_otp_secret_key_salt = generate_random_base64_encoded_salt

          decode_salt_if_encoded(salt)
        end

        def generate_random_base64_encoded_salt
          prefix = '_'
          prefix + [SecureRandom.random_bytes].pack('m')
        end

        def decode_salt_if_encoded(salt)
          salt.slice(0).eql?('_') ? salt.slice(1..-1).unpack('m').first : salt
        end
      end
    end
  end
end
