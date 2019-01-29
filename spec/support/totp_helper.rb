# Helper class to simulate a user generating TOTP codes from a secret key
class TotpHelper
  def initialize(secret_key, otp_length)
    @secret_key = secret_key
    @otp_length = otp_length
  end

  def totp_code(time = Time.now)
    ROTP::TOTP.new(@secret_key, digits: @otp_length).at(time)
  end
end
