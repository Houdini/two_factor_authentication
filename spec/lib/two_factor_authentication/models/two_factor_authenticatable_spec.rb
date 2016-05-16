require 'spec_helper'
include AuthenticatedModelHelper

describe Devise::Models::TwoFactorAuthenticatable do
  describe '#create_direct_otp' do
    let(:instance) { build_guest_user }

    it 'set direct_otp field' do
      expect(instance.direct_otp).to be_nil
      instance.create_direct_otp
      expect(instance.direct_otp).not_to be_nil
    end

    it 'set direct_otp_send_at field to current time' do
      Timecop.freeze() do
        instance.create_direct_otp
        expect(instance.direct_otp_sent_at).to eq(Time.now)
      end
    end

    it 'honors .direct_otp_length' do
      expect(instance.class).to receive(:direct_otp_length).and_return(10)
      instance.create_direct_otp
      expect(instance.direct_otp.length).to equal(10)

      expect(instance.class).to receive(:direct_otp_length).and_return(6)
      instance.create_direct_otp
      expect(instance.direct_otp.length).to equal(6)
    end

    it "honors 'length' in options paramater" do
      instance.create_direct_otp(length: 8)
      expect(instance.direct_otp.length).to equal(8)
      instance.create_direct_otp(length: 10)
      expect(instance.direct_otp.length).to equal(10)
    end
  end

  describe '#create_backup_code' do
    let(:instance) { build_guest_user }

    it "honors .backup_code_count" do
      expect(instance.class).to receive(:backup_code_count).and_return(2)
      instance.create_backup_codes
      expect(instance.backup_codes.split().length).to equal(2)
    end

    it "honors 'count' in options paramater" do
      instance.create_backup_codes(count: 3)
      expect(instance.backup_codes.split().length).to equal(3)
    end

    it "honors .backup_code_length" do
      expect(instance.class).to receive(:backup_code_length).and_return(2)
      expect(instance.class).to receive(:backup_code_count).and_return(1)
      expect(instance.create_backup_codes[0].length).to equal(2)
    end

    it "honors 'length' in options paramater" do
      expect(instance.class).to receive(:backup_code_count).and_return(1)
      expect(instance.create_backup_codes(length: 2)[0].length).to equal(2)
    end
  end

  describe '#authenticate_direct_otp' do
    let(:instance) { build_guest_user }

    it 'fails if no direct_otp has been set' do
      expect(instance.authenticate_direct_otp('12345')).to eq(false)
    end

    context 'after generating an OTP' do
      before do
        instance.create_direct_otp
      end

      it 'accepts correct OTP' do
        Timecop.freeze(Time.now + instance.class.direct_otp_valid_for - 1.second)
        expect(instance.authenticate_direct_otp(instance.direct_otp)).to eq(true)
      end

      it 'rejects invalid OTP' do
        Timecop.freeze(Time.now + instance.class.direct_otp_valid_for - 1.second)
        expect(instance.authenticate_direct_otp('12340')).to eq(false)
      end

      it 'rejects expired OTP' do
        Timecop.freeze(Time.now + instance.class.direct_otp_valid_for + 1.second)
        expect(instance.authenticate_direct_otp(instance.direct_otp)).to eq(false)
      end

      it 'prevents code re-use' do
        expect(instance.authenticate_direct_otp(instance.direct_otp)).to eq(true)
        expect(instance.authenticate_direct_otp(instance.direct_otp)).to eq(false)
      end
    end
  end

  describe '#authenticate_backup_code' do
    let(:instance) { build_guest_user }
    it 'fails if no backup codes have been set' do
      expect(instance.authenticate_backup_code('12345')).to eq(false)
    end

    context 'after generating codes' do
      before do
        @codes = instance.create_backup_codes
      end

      it 'accept first code' do
        expect(instance.authenticate_backup_code(@codes[0])).to eq(true)
      end

      it 'accept last code' do
        expect(instance.authenticate_backup_code(@codes[-1])).to eq(true)
      end

      it 'accept all generated codes' do
        @codes.each do |code|
          expect(instance.authenticate_backup_code(code)).to eq(true)
        end
      end

      it 'rejects invalid OTP' do
        expect(instance.authenticate_backup_code('12340')).to eq(false)
      end

      it 'prevents code re-use' do
        expect(instance.authenticate_backup_code(@codes[0])).to eq(true)
        expect(instance.authenticate_backup_code(@codes[0])).to eq(false)
      end
    end
  end

  describe '#authenticate_totp' do
    shared_examples 'authenticate_totp' do |instance|
      before do
        instance.otp_secret_key = '2z6hxkdwi3uvrnpn'
        instance.totp_timestamp = nil
        @totp_helper = TotpHelper.new(instance.otp_secret_key, instance.class.otp_length)
      end

      def do_invoke(code, user)
        user.authenticate_totp(code)
      end

      it 'authenticates a recently created code' do
        code = @totp_helper.totp_code
        expect(do_invoke(code, instance)).to eq(true)
      end

      it 'does not authenticate an old code' do
        code = @totp_helper.totp_code(1.minutes.ago.to_i)
        expect(do_invoke(code, instance)).to eq(false)
      end

      it 'prevents code reuse' do
        code = @totp_helper.totp_code
        expect(do_invoke(code, instance)).to eq(true)
        expect(do_invoke(code, instance)).to eq(false)
      end
    end

    it_behaves_like 'authenticate_totp', GuestUser.new
    it_behaves_like 'authenticate_totp', EncryptedUser.new
  end

  describe '#send_two_factor_authentication_code' do
    let(:instance) { build_guest_user }

    it 'raises an error by default' do
      expect { instance.send_two_factor_authentication_code(123) }.
        to raise_error(NotImplementedError)
    end

    it 'is overrideable' do
      def instance.send_two_factor_authentication_code(code)
        'Code sent'
      end
      expect(instance.send_two_factor_authentication_code(123)).to eq('Code sent')
    end
  end

  describe '#provisioning_uri' do

    shared_examples 'provisioning_uri' do |instance|
      it 'fails until generate_totp_secret is called' do
        expect { instance.provisioning_uri }.to raise_error(Exception)
      end

      describe 'with secret set' do
        before do
          instance.email = 'houdini@example.com'
          instance.otp_secret_key = instance.generate_totp_secret
        end

        it "returns uri with user's email" do
          expect(instance.provisioning_uri).
            to match(%r{otpauth://totp/houdini@example.com\?secret=\w{16}})
        end

        it 'returns uri with issuer option' do
          expect(instance.provisioning_uri('houdini')).
            to match(%r{otpauth://totp/houdini\?secret=\w{16}$})
        end

        it 'returns uri with issuer option' do
          require 'cgi'
          uri = URI.parse(instance.provisioning_uri('houdini', issuer: 'Magic'))
          params = CGI.parse(uri.query)

          expect(uri.scheme).to eq('otpauth')
          expect(uri.host).to eq('totp')
          expect(uri.path).to eq('/Magic:houdini')
          expect(params['issuer'].shift).to eq('Magic')
          expect(params['secret'].shift).to match(/\w{16}/)
        end
      end
    end

    it_behaves_like 'provisioning_uri', GuestUser.new
    it_behaves_like 'provisioning_uri', EncryptedUser.new
  end

  describe '#generate_totp_secret' do
    shared_examples 'generate_totp_secret' do |klass|
      let(:instance) { klass.new }

      it 'returns a 16 character string' do
        secret = instance.generate_totp_secret

        expect(secret).to match(/\w{16}/)
      end
    end

    it_behaves_like 'generate_totp_secret', GuestUser
    it_behaves_like 'generate_totp_secret', EncryptedUser
  end

  describe '#confirm_totp_secret' do
    shared_examples 'confirm_totp_secret' do |klass|
      let(:instance) { klass.new }
      let(:secret) { instance.generate_totp_secret }
      let(:totp_helper) { TotpHelper.new(secret, instance.class.otp_length) }

      it 'populates otp_secret_key column when given correct code' do
        instance.confirm_totp_secret(secret, totp_helper.totp_code)

        expect(instance.otp_secret_key).to match(secret)
      end

      it 'does not populate otp_secret_key when when given incorrect code' do
        instance.confirm_totp_secret(secret, '123')
        expect(instance.otp_secret_key).to be_nil
      end

      it 'returns true when given correct code' do
        expect(instance.confirm_totp_secret(secret, totp_helper.totp_code)).to be true
      end

      it 'returns false when given incorrect code' do
        expect(instance.confirm_totp_secret(secret, '123')).to be false
      end

    end

    it_behaves_like 'confirm_totp_secret', GuestUser
    it_behaves_like 'confirm_totp_secret', EncryptedUser
  end

  describe '#max_login_attempts' do
    let(:instance) { build_guest_user }

    before do
      @original_max_login_attempts = GuestUser.max_login_attempts
      GuestUser.max_login_attempts = 3
    end

    after { GuestUser.max_login_attempts = @original_max_login_attempts }

    it 'returns class setting' do
      expect(instance.max_login_attempts).to eq(3)
    end

    it 'returns false as boolean' do
      instance.second_factor_attempts_count = nil
      expect(instance.max_login_attempts?).to be_falsey
      instance.second_factor_attempts_count = 0
      expect(instance.max_login_attempts?).to be_falsey
      instance.second_factor_attempts_count = 1
      expect(instance.max_login_attempts?).to be_falsey
      instance.second_factor_attempts_count = 2
      expect(instance.max_login_attempts?).to be_falsey
    end

    it 'returns true as boolean after too many attempts' do
      instance.second_factor_attempts_count = 3
      expect(instance.max_login_attempts?).to be_truthy
      instance.second_factor_attempts_count = 4
      expect(instance.max_login_attempts?).to be_truthy
    end
  end

  describe '.has_one_time_password' do
    context 'when encrypted: true option is passed' do
      let(:instance) { EncryptedUser.new }

      it 'encrypts otp_secret_key with iv, salt, and encoding' do
        instance.otp_secret_key = '2z6hxkdwi3uvrnpn'

        expect(instance.encrypted_otp_secret_key).to match(/.{44}/)

        expect(instance.encrypted_otp_secret_key_iv).to match(/.{24}/)

        expect(instance.encrypted_otp_secret_key_salt).to match(/.{25}/)
      end

      it 'does not encrypt a nil otp_secret_key' do
        instance.otp_secret_key = nil

        expect(instance.encrypted_otp_secret_key).to be_nil

        expect(instance.encrypted_otp_secret_key_iv).to be_nil

        expect(instance.encrypted_otp_secret_key_salt).to be_nil
      end

      it 'does not encrypt an empty otp_secret_key' do
        instance.otp_secret_key = ''

        expect(instance.encrypted_otp_secret_key).to eq ''

        expect(instance.encrypted_otp_secret_key_iv).to be_nil

        expect(instance.encrypted_otp_secret_key_salt).to be_nil
      end

      it 'raises an error when Devise.otp_secret_encryption_key is not set' do
        allow(Devise).to receive(:otp_secret_encryption_key).and_return nil

        # This error is raised by the encryptor gem
        expect { instance.otp_secret_key = '2z6hxkdwi3uvrnpn' }.
          to raise_error ArgumentError
      end

      it 'passes in the correct options to Encryptor' do
        instance.otp_secret_key = 'testing'
        iv = instance.encrypted_otp_secret_key_iv
        salt = instance.encrypted_otp_secret_key_salt

        encrypted = Encryptor.encrypt(
          value: 'testing',
          key: Devise.otp_secret_encryption_key,
          iv: iv.unpack('m').first,
          salt: salt.unpack('m').first
        )

        expect(instance.encrypted_otp_secret_key).to eq [encrypted].pack('m')
      end

      it 'varies the iv per instance' do
        instance.otp_secret_key = 'testing'
        user2 = EncryptedUser.new
        user2.otp_secret_key = 'testing'

        expect(user2.encrypted_otp_secret_key_iv).
          to_not eq instance.encrypted_otp_secret_key_iv
      end

      it 'varies the salt per instance' do
        instance.otp_secret_key = 'testing'
        user2 = EncryptedUser.new
        user2.otp_secret_key = 'testing'

        expect(user2.encrypted_otp_secret_key_salt).
          to_not eq instance.encrypted_otp_secret_key_salt
      end
    end
  end
end
