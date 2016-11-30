require 'rqrcode'
require 'devise/version'

class Devise::TwoFactorAuthenticationController < DeviseController
  prepend_before_action :authenticate_scope!
  before_action :prepare_and_validate, :handle_two_factor_authentication
  before_action :set_qr, only: [:new, :create]

  def show
    unless resource.otp_enabled
      return redirect_to({ action: :new }, notice: I18n.t('devise.two_factor_authentication.totp_not_enabled'))
    end
  end

  def new
    if resource.otp_enabled
      return redirect_to({ action: :edit }, notice: I18n.t('devise.two_factor_authentication.totp_already_enabled'))
    end
  end

  def edit
  end

  def create
    return render :new if params[:code].nil? || params[:totp_secret].nil?
    if resource.confirm_otp(params[:totp_secret], params[:code]) && resource.save
      after_two_factor_success_for(resource)
    else
      set_flash_message :notice, :confirm_failed, now: true
      render :new
    end
  end

  def update
    return render :edit if params[:code].nil?
    if resource.authenticate_otp(params[:code]) && resource.disable_otp
      redirect_to after_two_factor_success_path_for(resource), notice: I18n.t('devise.two_factor_authentication.remove_success')
    else
      set_flash_message :notice, :remove_failed, now: true
      render :edit
    end
  end

  def verify
    return render :show if params[:code].nil?

    if resource.authenticate_otp(params[:code])
      after_two_factor_success_for(resource)
    else
      after_two_factor_fail_for(resource)
    end
  end

  def resend_code
    resource.send_new_otp

    respond_to do |format|
      format.html { redirect_to send("#{resource_name}_two_factor_authentication_path"), notice: I18n.t('devise.two_factor_authentication.code_has_been_sent') }
      format.json { head :no_content, status: :ok }
    end
  end

  private

  def set_qr
    @totp_secret = resource.generate_totp_secret
    provisioning_uri = resource.provisioning_uri(nil, otp_secret_key: @totp_secret)
    @qr = RQRCode::QRCode.new(provisioning_uri).as_png(size: 250).to_data_url
  end

  def after_two_factor_success_for(resource)
    set_remember_two_factor_cookie(resource)
    warden.session(resource_name)[TwoFactorAuthentication::NEED_AUTHENTICATION] = false
    # For compatability with devise versions below v4.2.0
    # https://github.com/plataformatec/devise/commit/2044fffa25d781fcbaf090e7728b48b65c854ccb
    if Devise::VERSION.to_f >= 4.2
      bypass_sign_in(resource, scope: resource_name)
    else
      sign_in(resource_name, resource, bypass: true)
    end
    set_flash_message :notice, :success
    resource.update_attribute(:second_factor_attempts_count, 0)

    redirect_to after_two_factor_success_path_for(resource)
  end

  def set_remember_two_factor_cookie(resource)
    expires_seconds = resource.class.remember_otp_session_for_seconds

    if expires_seconds && expires_seconds > 0
      cookies.signed[TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME] = {
          value: "#{resource.class}-#{resource.public_send(Devise.second_factor_resource_id)}",
          expires: expires_seconds.from_now
      }
    end
  end

  def after_two_factor_success_path_for(resource)
    stored_location_for(resource_name) || :root
  end

  def after_two_factor_fail_for(resource)
    resource.second_factor_attempts_count += 1
    resource.save
    set_flash_message :alert, :attempt_failed, now: true

    if resource.max_login_attempts?
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
