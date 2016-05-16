class GuestUser
  extend ActiveModel::Callbacks
  include ActiveModel::Validations
  include Devise::Models::TwoFactorAuthenticatable

  define_model_callbacks :create
  attr_accessor :direct_otp, :direct_otp_sent_at, :otp_secret_key, :email,
    :second_factor_attempts_count, :totp_timestamp, :backup_codes

  mattr_accessor :pepper
  @@pepper = nil

  mattr_accessor :stretches
  @@stretches = 2

  def update_attributes(attrs)
    attrs.each do |key, value|
      send(key.to_s + '=', value)
    end
  end

  has_one_time_password
end
