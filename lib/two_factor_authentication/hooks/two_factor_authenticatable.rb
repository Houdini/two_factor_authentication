Warden::Manager.after_authentication do |user, auth, options|
  if Object.const_defined?('OtpSender') && OtpSender.new(user).respond_to?(:before_otp)
    OtpSender.new(user).before_otp
  end

  if user.respond_to?(:need_two_factor_authentication?) &&
      !auth.env["action_dispatch.cookies"].signed[TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME]
    if auth.session(options[:scope])[TwoFactorAuthentication::NEED_AUTHENTICATION] = user.need_two_factor_authentication?(auth.request)
      user.send_two_factor_authentication_code
    end
  end
end
