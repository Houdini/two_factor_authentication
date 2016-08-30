module ControllerHelper
  def sign_in(user = create_user('not_encrypted'))
    allow(warden).to receive(:authenticated?).with(:user).and_return(true)
    allow(controller).to receive(:current_user).and_return(user)
    warden.session(:user)[TwoFactorAuthentication::NEED_AUTHENTICATION] = true
  end
end

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include ControllerHelper, type: :controller

  config.before(:example, type: :controller) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end
end
