Warden::Manager.after_authentication do |user, auth, options|
  if auth.env["action_dispatch.cookies"]
    expected_cookie_value = "#{user.class}-#{user.public_send(Devise.second_factor_resource_id)}"
    actual_cookie_value = auth.env["action_dispatch.cookies"]
                              .signed[TwoFactorAuthentication::name_for(:remember_tfa_cookie_name,
                                                                        options[:scope])]
    bypass_by_cookie = actual_cookie_value == expected_cookie_value
  end

  if user.respond_to?(:need_two_factor_authentication?) && !bypass_by_cookie
    if auth.session(options[:scope])[TwoFactorAuthentication::name_for(
        :need_authentication, options[:scope]
    )] = user.need_two_factor_authentication?(auth.request) and user.class.subdomain_in_scope?
      user.send_new_otp if user.send_new_otp_after_login?
    end
  end
end

Warden::Manager.before_logout do |user, auth, _options|
  auth.cookies.delete TwoFactorAuthentication::name_for(:remember_tfa_cookie_name,
                                                        _options[:scope]) if Devise.delete_cookie_on_logout
end
