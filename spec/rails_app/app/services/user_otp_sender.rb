class UserOtpSender
  def initialize(user)
    @user = user
  end

  def reset_otp_state
    @user.update_attributes(email: 'updated@example.com')
  end
end
