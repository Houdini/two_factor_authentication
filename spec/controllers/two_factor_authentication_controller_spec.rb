require 'spec_helper'

describe Devise::TwoFactorAuthenticationController, type: :controller do
  describe 'is_fully_authenticated? helper' do
    def post_code(code)
      if Rails::VERSION::MAJOR >= 5
        post :update, params: { code: code }
      else
        post :update, code: code
      end
    end

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
end
