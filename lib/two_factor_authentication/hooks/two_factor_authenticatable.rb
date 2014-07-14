Warden::Manager.after_authentication do |user, auth, options|
  if user.respond_to?(:need_two_factor_authentication?)
    if auth.session(options[:scope])[TwoFactorAuthentication::NEED_AUTHENTICATION] = user.need_two_factor_authentication?(auth.request)
      user.send_two_factor_authentication_code
    end
  end
end
