Warden::Manager.after_authentication do |user, auth, options|
  reset_otp_state_for(user)

  expected_cookie_value = "#{user.class}-#{user.id}"
  actual_cookie_value = auth.env["action_dispatch.cookies"].signed[TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME]
  if actual_cookie_value.nil?
    bypass_by_cookie = false
  else
    bypass_by_cookie = actual_cookie_value == expected_cookie_value
  end

  if user.respond_to?(:need_two_factor_authentication?) && !bypass_by_cookie
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
  klass = class_from_string(klass_string)

  return unless klass

  otp_sender = klass.new(user)

  otp_sender.reset_otp_state if otp_sender.respond_to?(:reset_otp_state)
end

def class_from_string(string)
  string.constantize
rescue NameError
  false
end
