require 'warden'

module FeaturesSpecHelper
  def warden
    request.env['warden']
  end

  def complete_sign_in_form_for(user)
    fill_in "Email", with: user.email
    fill_in "Password", with: 'password'
    find('.actions input').click # 'Sign in' or 'Log in'
  end

  def set_cookie key, value
    page.driver.browser.set_cookie [key, value].join('=')
  end

  def get_cookie key
    Capybara.current_session.driver.request.cookies[key]
  end

  def set_tfa_cookie value
    set_cookie TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME, value
  end

  def get_tfa_cookie
    get_cookie TwoFactorAuthentication::REMEMBER_TFA_COOKIE_NAME
  end
end

RSpec.configure do |config|
  config.include Warden::Test::Helpers, type: :feature
  config.include FeaturesSpecHelper, type: :feature

  config.before(:each) do
    Warden.test_mode!
  end

  config.after(:each) do
    Warden.test_reset!
  end
end
