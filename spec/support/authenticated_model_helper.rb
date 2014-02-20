module AuthenticatedModelHelper

  class User
    extend ActiveModel::Callbacks
    include ActiveModel::Validations
    include Devise::Models::TwoFactorAuthenticatable

    define_model_callbacks :create
    attr_accessor :otp_secret_key, :email

    has_one_time_password
  end

  class UserWithOverrides < User

    def send_two_factor_authentication_code
      "Code sent"
    end
  end

  def create_new_user
    User.new
  end

  def create_new_user_with_overrides
    UserWithOverrides.new
  end

end