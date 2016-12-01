require 'spec_helper'

describe Devise::TwoFactorAuthenticationController, type: :controller do
  describe 'Enabling otp' do
    before do
      sign_in create_user('not_encrypted', otp_enabled: false)
    end

    describe 'with direct code' do
      context 'when user has not entered any OTP yet' do
        it 'returns false' do
          get :show

          expect(subject.current_user.otp_enabled).to eq false
        end
      end

      context 'when users enters valid OTP code' do
        it 'returns true' do
          controller.current_user.send_new_otp
          post :create, code: controller.current_user.direct_otp, totp_secret: 'secret'

          expect(subject.current_user.otp_enabled).to eq true
        end
      end

      context 'when user enters an invalid OTP' do
        it 'return false' do
          post :create, code: '12345', totp_secret: 'secret'

          expect(subject.current_user.otp_enabled).to eq false
        end
      end
    end

    describe 'with totp app' do
      context 'when user has not entered any OTP yet' do
        it 'returns false' do
          get :show

          expect(subject.current_user.otp_enabled).to eq false
        end
      end

      context 'when users enters valid TOTP code' do
        it 'returns true' do
          secret = controller.current_user.generate_totp_secret
          totp = ROTP::TOTP.new(secret)
          post :create, code: totp.now, totp_secret: secret

          expect(subject.current_user.otp_enabled).to eq true
        end
      end

      context 'when user enters an invalid OTP' do
        it 'return false' do
          post :create, code: '12345', totp_secret: 'secret'

          expect(subject.current_user.otp_enabled).to eq false
        end
      end
    end
  end

  describe 'Disabling otp' do
    before do
      sign_in create_user('not_encrypted', otp_enabled: true)
      secret = controller.current_user.generate_totp_secret
      controller.current_user.update(otp_secret_key: secret)
    end

    describe 'with direct code' do
      context 'when user has not entered any OTP yet' do
        it 'returns true' do
          get :edit

          expect(subject.current_user.otp_enabled).to eq true
        end
      end

      context 'when users enters valid OTP code' do
        it 'returns false' do
          controller.current_user.send_new_otp
          post :update, code: controller.current_user.direct_otp

          expect(subject.current_user.otp_enabled).to eq false
        end
      end

      context 'when user enters an invalid OTP' do
        it 'return true' do
          post :update, code: '12345'

          expect(subject.current_user.otp_enabled).to eq true
        end
      end
    end

    describe 'with totp app' do
      context 'when user has not entered any OTP yet' do
        it 'returns true' do
          get :edit

          expect(subject.current_user.otp_enabled).to eq true
        end
      end

      context 'when users enters valid TOTP code' do
        it 'returns true' do
          secret = controller.current_user.otp_secret_key
          totp = ROTP::TOTP.new(secret)
          post :update, code: totp.now

          expect(subject.current_user.otp_enabled).to eq false
        end
      end

      context 'when user enters an invalid OTP' do
        it 'return false' do
          post :update, code: '12345'

          expect(subject.current_user.otp_enabled).to eq true
        end
      end
    end
  end

  describe 'is_fully_authenticated? helper' do
    before do
      sign_in create_user('not_encrypted', otp_enabled: true)
    end

    context 'after user enters valid OTP code' do
      it 'returns true' do
        controller.current_user.send_new_otp
        post :verify, code: controller.current_user.direct_otp
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
        post :verify, code: '12345'

        expect(subject.is_fully_authenticated?).to eq false
      end
    end
  end
end
