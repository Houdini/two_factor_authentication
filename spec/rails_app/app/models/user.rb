class User < ActiveRecord::Base
  devise :two_factor_authenticatable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :two_factor_authenticatable

  has_one_time_password

  def send_two_factor_authentication_code
    SMSProvider.send_message(to: phone_number, body: otp_code)
  end

  def phone_number
    '14159341234'
  end
end
