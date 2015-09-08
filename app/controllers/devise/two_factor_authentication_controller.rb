class Devise::TwoFactorAuthenticationController < DeviseController
  prepend_before_filter :authenticate_scope!
  before_filter :prepare_and_validate, :handle_two_factor_authentication

  def show
  end

  def update
    render :show and return if params[:code].nil?

    if resource.authenticate_otp(params[:code])
      expires_seconds = resource.class.remember_otp_session_for_seconds
      if expires_seconds && expires_seconds > 0
        cookies.signed[TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME] = {
          value: true,
          expires: expires_seconds.from_now
        }
      end
      warden.session(resource_name)[TwoFactorAuthentication::NEED_AUTHENTICATION] = false
      sign_in resource_name, resource, :bypass => true
      set_flash_message :notice, :success
      redirect_to stored_location_for(resource_name) || :root
      resource.update_attribute(:second_factor_attempts_count, 0)
    else
      resource.second_factor_attempts_count += 1
      resource.save
      flash.now[:error] = find_message(:attempt_failed)
      if resource.max_login_attempts?
        sign_out(resource)
        render :max_login_attempts_reached
      else
        render :show
      end
    end
  end

  private

    def authenticate_scope!
      self.resource = send("current_#{resource_name}")
    end

    def prepare_and_validate
      redirect_to :root and return if resource.nil?
      @limit = resource.max_login_attempts
      if resource.max_login_attempts?
        sign_out(resource)
        render :max_login_attempts_reached and return
      end
    end
end
