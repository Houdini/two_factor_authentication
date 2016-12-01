class EncryptedUser
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include Devise::Models::TwoFactorAuthenticatable

  define_model_callbacks :create
  attr_accessor :encrypted_otp_secret_key,
                :encrypted_otp_secret_key_iv,
                :encrypted_otp_secret_key_salt,
                :email,
                :second_factor_attempts_count,
                :totp_timestamp,
                :otp_enabled

  has_one_time_password(encrypted: true)
end
