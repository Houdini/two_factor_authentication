class Devise::TwoFactorAuthenticationController < DeviseController
  prepend_before_action :authenticate_scope!
  before_action :prepare_and_validate, :handle_two_factor_authentication

  OTP_CODE = 1
  TOTP_CODE = 2
  BACKUP_CODE = 3

  def show
  end

  def show_backup
  end

  def show_totp
  end

  def use_backup_code
    render :show_backup
  end

  def use_totp_code
    render :show_totp
  end

  def update
    type = if !params[:code].nil?
             OTP_CODE
           elsif !params[:totp_code].nil?
             TOTP_CODE
           elsif !params[:backup_code].nil?
             BACKUP_CODE
           else
             render :show and return
           end

    auth_status = if type == BACKUP_CODE
                    resource.authenticate_backup_code(params[:backup_code])
                  elsif type == OTP_CODE
                    resource.authenticate_otp(params[:code])
                  elsif type == TOTP_CODE
                    resource.authenticate_totp(params[:totp_code])
                  end

    if auth_status
      after_two_factor_success_for(resource)
    else
      after_two_factor_fail_for(resource, type)
    end
  end

  def resend_code
    resource.send_new_otp
    redirect_to send("#{resource_name}_two_factor_authentication_path"), notice: I18n.t('devise.two_factor_authentication.code_has_been_sent')
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
    bypass_sign_in(resource, scope: resource_name)
    set_flash_message :notice, :success
    resource.update_attribute(:second_factor_attempts_count, 0)

    redirect_to after_two_factor_success_path_for(resource)
  end

  def after_two_factor_success_path_for(resource)
    stored_location_for(resource_name) || :root
  end

  def after_two_factor_fail_for(resource, type)
    resource.second_factor_attempts_count += 1
    resource.save
    set_flash_message :alert, :attempt_failed, now: true

    if resource.max_login_attempts?
      sign_out(resource)
      render :max_login_attempts_reached
    else
      case type
      when OTP_CODE
        render :show
      when BACKUP_CODE
        render :show_backup
      when TOTP_CODE
        render :show_totp
      else
        raise "Invalid OTP type: #{type}"
      end
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
