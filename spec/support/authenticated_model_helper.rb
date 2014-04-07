module AuthenticatedModelHelper

  class UserWithOverrides < User

    def send_two_factor_authentication_code
      "Code sent"
    end
  end

  def create_new_user
    User.new
  end

  def create_new_user_with_overrides
    UserWithOverrides.new
  end

end
