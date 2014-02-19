module AuthenticatedModelHelper

  class User
    extend ActiveModel::Callbacks
    include ActiveModel::Validations
    include Devise::Models::TwoFactorAuthenticatable

    define_model_callbacks :create
    attr_accessor :otp_secret_key, :email

    has_one_time_password
  end

  def create_new_user
    User.new
  end

end