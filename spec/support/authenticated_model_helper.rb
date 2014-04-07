module AuthenticatedModelHelper

  def build_guest_user
    GuestUser.new
  end

  def create_user(attributes={})
    User.create!(valid_attributes(attributes))
  end

  def valid_attributes(attributes={})
    {
      nickname: 'Marissa',
      email: generate_unique_email,
      password: 'password',
      password_confirmation: 'password'
    }.merge(attributes)
  end

  def generate_unique_email
    @@email_count ||= 0
    @@email_count += 1
    "user#{@@email_count}@example.com"
  end

end

RSpec.configuration.send(:include, AuthenticatedModelHelper)
