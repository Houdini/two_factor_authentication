Warden::Manager.after_authentication do |user, auth, options|
  reset_otp_state_for(user)

  if user.respond_to?(:need_two_factor_authentication?) &&
      !auth.env["action_dispatch.cookies"].signed[TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME]
    if auth.session(options[:scope])[TwoFactorAuthentication::NEED_AUTHENTICATION] = user.need_two_factor_authentication?(auth.request)
      user.send_two_factor_authentication_code
    end
  end
end

Warden::Manager.before_logout do |user, _auth, _options|
  reset_otp_state_for(user)
end

def reset_otp_state_for(user)
  klass_string = "#{user.class}OtpSender"
  return unless Object.const_defined?(klass_string)

  klass = Object.const_get(klass_string)

  otp_sender = klass.new(user)

  otp_sender.reset_otp_state if otp_sender.respond_to?(:reset_otp_state)
end
