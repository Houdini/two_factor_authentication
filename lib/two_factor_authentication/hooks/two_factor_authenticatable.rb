Warden::Manager.after_authentication do |user, auth, options|
  if auth.env["action_dispatch.cookies"]
    cookie = auth.env["action_dispatch.cookies"].signed[TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME]
    bypass_by_cookie   = cookie.present?
    bypass_by_cookie &&= cookie["user_class"] == user.class.to_s
    bypass_by_cookie &&= cookie["user_id"]    == user.id.to_s
    bypass_by_cookie &&= Time.current         <= cookie["created_at"].to_datetime + user.class.remember_otp_session_for_seconds
  end

  if user.respond_to?(:need_two_factor_authentication?) && !bypass_by_cookie
    if auth.session(options[:scope])[TwoFactorAuthentication::NEED_AUTHENTICATION] = user.need_two_factor_authentication?(auth.request)
      user.send_new_otp if user.send_new_otp_after_login?
    end
  end
end

Warden::Manager.before_logout do |user, auth, _options|
  auth.cookies.delete TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME if Devise.delete_cookie_on_logout
end
