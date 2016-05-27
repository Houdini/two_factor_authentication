class Devise::TwoFactorAuthenticationController < DeviseController
  if Rails::VERSION::MAJOR >= 4
    prepend_before_action :authenticate_scope!
    before_action :prepare_and_validate, :handle_two_factor_authentication
  else
    prepend_before_filter :authenticate_scope!
    before_filter :prepare_and_validate, :handle_two_factor_authentication
  end

  def show
  end

  def update
    render :show and return if params[:code].nil?

    if resource.authenticate_otp(params[:code])
      after_two_factor_success_for(resource)
    else
      after_two_factor_fail_for(resource)
    end
  end

  def resend_code
    resource.send_two_factor_authentication_code
    redirect_to user_two_factor_authentication_path, notice: I18n.t('devise.two_factor_authentication.code_has_been_sent')
  end

  private

  def after_two_factor_success_for(resource)
    expires_seconds = resource.class.remember_otp_session_for_seconds

    if expires_seconds && expires_seconds > 0
      cookies.signed[TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME] = {
          value: "#{resource.class}-#{resource.id}",
          expires: expires_seconds.from_now
      }
    end

    warden.session(resource_name)[TwoFactorAuthentication::NEED_AUTHENTICATION] = false
    sign_in resource_name, resource, :bypass => true
    set_flash_message :notice, :success
    resource.update_attribute(:second_factor_attempts_count, 0)

    redirect_to after_two_factor_success_path_for(resource)
  end

  def after_two_factor_success_path_for(resource)
    stored_location_for(resource_name) || :root
  end

  def after_two_factor_fail_for(resource)
    resource.second_factor_attempts_count += 1
    resource.save
    set_flash_message :alert, find_message(:attempt_failed), now: true

    if resource.max_login_attempts?
      resource.locked_at = Time.now if resource.respond_to?(:locked_at=)
      sign_out(resource)
      render :max_login_attempts_reached

    else
      render :show
    end
  end

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
