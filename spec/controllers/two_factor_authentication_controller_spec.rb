require 'spec_helper'

describe Devise::TwoFactorAuthenticationController, type: :controller do
  def post_code(code)
    if Rails::VERSION::MAJOR >= 5
      post :update, params: { code: code }
    else
      post :update, code: code
    end
  end

  describe 'is_fully_authenticated? helper' do
    before do
      sign_in
    end

    context 'after user enters valid OTP code' do
      it 'returns true' do
        controller.current_user.send_new_otp
        post_code controller.current_user.direct_otp
        expect(subject.is_fully_authenticated?).to eq true
      end
    end

    context 'when user has not entered any OTP yet' do
      it 'returns false' do
        get :show

        expect(subject.is_fully_authenticated?).to eq false
      end
    end

    context 'when user enters an invalid OTP' do
      it 'returns false' do
        post_code '12345'

        expect(subject.is_fully_authenticated?).to eq false
      end
    end
  end

  describe 'PUT update' do
    render_views

    let(:user) { create_user }

    before do
      sign_in user
      user.send_new_otp
    end

    it 'responds with 422 and re-renders the form for an invalid code' do
      post_code '00000000'

      expect(response).to have_http_status(422)
      expect(response.body).to include('Enter the code that was sent to you')
      expect(user.reload.second_factor_attempts_count).to eq(1)
    end

    it 'responds with 422 and signs out when the last attempt fails' do
      user.update!(second_factor_attempts_count: User.max_login_attempts - 1)

      post_code '00000000'

      expect(response).to have_http_status(422)
      expect(response.body).to include('Access completely denied')
    end
  end

  context 'with a second devise scope' do
    let(:secure_user) { create_secure_user }

    before do
      @request.env['devise.mapping'] = Devise.mappings[:secure_user]
      sign_in secure_user, scope: :secure_user
    end

    it 'reports the scope of the current resource as not fully authenticated' do
      get :show

      expect(response).to have_http_status(200)
      expect(subject.is_fully_authenticated?).to eq false
      expect(subject.is_fully_authenticated?(:secure_user)).to eq false
    end

    it 'reports the scope as fully authenticated after a valid code' do
      secure_user.send_new_otp
      post_code secure_user.reload.direct_otp

      expect(subject.is_fully_authenticated?).to eq true
      expect(subject.is_fully_authenticated?(:secure_user)).to eq true
    end
  end
end
