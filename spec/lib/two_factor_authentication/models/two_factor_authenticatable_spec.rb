require 'spec_helper'
include AuthenticatedModelHelper

describe Devise::Models::TwoFactorAuthenticatable do
  describe '#otp_code' do
    shared_examples 'otp_code' do |instance|
      subject { instance.otp_code(time) }
      let(:time) { 1_392_852_456 }

      it 'returns an error if no secret is set' do
        expect { subject }.to raise_error Exception
      end

      context 'secret is set' do
        before :each do
          instance.otp_secret_key = '2z6hxkdwi3uvrnpn'
        end

        it 'does not return an error' do
          subject
        end

        it 'matches Devise configured length' do
          expect(subject.length).to eq(Devise.otp_length)
        end

        context 'with a known time' do
          let(:time) { 1_392_852_756 }

          it 'returns a known result' do
            expect(subject).
              to eq('0000000524562202'.split(//).last(Devise.otp_length).join)
          end
        end

        context 'with a known time yielding a result with less than 6 digits' do
          let(:time) { 1_393_065_856 }

          it 'returns a known result padded with zeroes' do
            expect(subject).
              to eq('0000001608007672'.split(//).last(Devise.otp_length).join)
          end
        end
      end
    end

    it_behaves_like 'otp_code', GuestUser.new
    it_behaves_like 'otp_code', EncryptedUser.new
  end

  describe '#authenticate_otp' do
    shared_examples 'authenticate_otp' do |instance|
      before :each do
        instance.otp_secret_key = '2z6hxkdwi3uvrnpn'
      end

      def do_invoke(code, user)
        user.authenticate_otp(code)
      end

      it 'authenticates a recently created code' do
        code = instance.otp_code
        expect(do_invoke(code, instance)).to eq(true)
      end

      it 'does not authenticate an old code' do
        code = instance.otp_code(1.minutes.ago.to_i)
        expect(do_invoke(code, instance)).to eq(false)
      end
    end

    it_behaves_like 'authenticate_otp', GuestUser.new
    it_behaves_like 'authenticate_otp', EncryptedUser.new
  end

  describe '#send_two_factor_authentication_code' do
    let(:instance) { build_guest_user }

    it 'raises an error by default' do
      expect { instance.send_two_factor_authentication_code }.
        to raise_error(NotImplementedError)
    end

    it 'is overrideable' do
      def instance.send_two_factor_authentication_code
        'Code sent'
      end
      expect(instance.send_two_factor_authentication_code).to eq('Code sent')
    end
  end

  describe '#provisioning_uri' do
    shared_examples 'provisioning_uri' do |instance|
      before do
        instance.email = 'houdini@example.com'
        instance.run_callbacks :create
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
        expect(uri.path).to eq('/houdini')
        expect(params['issuer'].shift).to eq('Magic')
        expect(params['secret'].shift).to match(/\w{16}/)
      end
    end

    it_behaves_like 'provisioning_uri', GuestUser.new
    it_behaves_like 'provisioning_uri', EncryptedUser.new
  end

  describe '#populate_otp_column' do
    shared_examples 'populate_otp_column' do |klass|
      let(:instance) { klass.new }

      it 'populates otp_column on create' do
        expect(instance.otp_secret_key).to be_nil

        # populate_otp_column called via before_create
        instance.run_callbacks :create

        expect(instance.otp_secret_key).to match(/\w{16}/)
      end

      it 'repopulates otp_column' do
        instance.run_callbacks :create
        original_key = instance.otp_secret_key

        instance.populate_otp_column

        expect(instance.otp_secret_key).to match(/\w{16}/)
        expect(instance.otp_secret_key).to_not eq(original_key)
      end
    end

    it_behaves_like 'populate_otp_column', GuestUser
    it_behaves_like 'populate_otp_column', EncryptedUser
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
          to raise_error ArgumentError, 'must specify a :key'
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
