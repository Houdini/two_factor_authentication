class SecureUser < ActiveRecord::Base
  devise :two_factor_authenticatable, :database_authenticatable, :validatable

  has_one_time_password(encrypted: true)

  def send_two_factor_authentication_code(code)
    SMSProvider.send_message(to: phone_number, body: code)
  end

  def phone_number
    '14155550000'
  end
end
