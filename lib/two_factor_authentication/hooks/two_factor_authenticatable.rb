Warden::Manager.after_authentication do |user, auth, options|
  if user.respond_to?(:need_two_factor_authentication?)
    need_code = user.need_two_factor_authentication?(auth.request)
    auth.session(options[:scope])[TwoFactorAuthentication::NEED_AUTHENTICATION] = need_code
    if need_code
      user.send_two_factor_authentication_code
    end
  end
end
