Warden::Manager.after_authentication do |user, auth, options|
  cookie_jar = auth.cookies || auth.env["action_dispatch.cookies"]
  if cookie_jar
    expected_cookie_value = "#{user.class}-#{user.public_send(Devise.second_factor_resource_id)}"
    actual_cookie_value = cookie_jar.signed[TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME]
    bypass_by_cookie = actual_cookie_value == expected_cookie_value
  end

  if user.respond_to?(:need_two_factor_authentication?) && !bypass_by_cookie
    if auth.session(options[:scope])[TwoFactorAuthentication::NEED_AUTHENTICATION] = user.need_two_factor_authentication?(auth.request)
      user.send_new_otp if user.send_new_otp_after_login?
    end
  end
end

Warden::Manager.before_logout do |user, auth, _options|
  should_delete = Devise.delete_cookie_on_logout
  
  if user.respond_to?(:delete_cookie_on_logout?)
    should_delete = user.delete_cookie_on_logout?
  end

  auth.cookies.delete TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME if should_delete
end
