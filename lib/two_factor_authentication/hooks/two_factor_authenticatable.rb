Warden::Manager.after_authentication do |user, auth, options|
  if auth.env["action_dispatch.cookies"]
    expected_cookie_value = "#{user.class}-#{user.public_send(Devise.second_factor_resource_id)}"
    actual_cookie_value = auth.env["action_dispatch.cookies"].signed[TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME]
    bypass_by_cookie = actual_cookie_value == expected_cookie_value
  end

  if user.respond_to?(:need_two_factor_authentication?) && !bypass_by_cookie
    if auth.session(options[:scope])[TwoFactorAuthentication::NEED_AUTHENTICATION] = user.need_two_factor_authentication?(auth.request)
      user.send_new_otp unless user.totp_enabled?
    end
  end
end

Warden::Manager.before_logout do |user, auth, _options|
  auth.cookies.delete TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME if Devise.delete_cookie_on_logout
end
