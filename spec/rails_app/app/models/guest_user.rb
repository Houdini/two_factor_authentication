class GuestUser
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include Devise::Models::TwoFactorAuthenticatable

  define_model_callbacks :create
  attr_accessor :otp_secret_key, :email, :second_factor_attempts_count

  has_one_time_password
end
