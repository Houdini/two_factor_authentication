require 'spec_helper'

describe Devise::TwoFactorAuthenticationController, type: :controller do
  describe 'is_fully_authenticated? helper' do
    before do
      sign_in
    end

    context 'after user enters valid OTP code' do
      it 'returns true' do
        post :update, code: controller.current_user.otp_code

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
        post :update, code: '12345'

        expect(subject.is_fully_authenticated?).to eq false
      end
    end
  end
end
