Warden::Manager.after_authentication do |user, auth, options|
  if user.respond_to?(:need_two_factor_authentication?)
    if auth.session(options[:scope])[:need_two_factor_authentication] = user.need_two_factor_authentication?(auth.request)
      code = user.generate_two_factor_code
      user.second_factor_pass_code = Digest::MD5.hexdigest(code)
      user.save
      user.send_two_factor_authentication_code(code)
    end
  end
end
