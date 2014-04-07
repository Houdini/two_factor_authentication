module AuthenticatedModelHelper

  class POROUser
    extend ActiveModel::Callbacks
    include ActiveModel::Validations
    include Devise::Models::TwoFactorAuthenticatable

    define_model_callbacks :create
    attr_accessor :otp_secret_key, :email, :second_factor_attempts_count

    has_one_time_password
  end

  class UserWithOverrides < POROUser
    def send_two_factor_authentication_code
      "Code sent"
    end
  end

  def create_new_user
    POROUser.new
  end

  def create_new_user_with_overrides
    UserWithOverrides.new
  end

  def create_user(attributes={})
    User.create!(valid_attributes(attributes))
  end

  def valid_attributes(attributes={})
    {
      email: generate_unique_email,
      password: 'password',
      password_confirmation: 'password'
    }.merge(attributes)
  end

  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "user#{@@email_count}@example.com"
  end

end

RSpec.configuration.send(:include, AuthenticatedModelHelper)
