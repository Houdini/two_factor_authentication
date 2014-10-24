require 'spec_helper'
include AuthenticatedModelHelper

describe Devise::Models::TwoFactorAuthenticatable, '#otp_code' do
  let(:instance) { build_guest_user }
  subject { instance.otp_code(time) }
  let(:time) { 1392852456 }

  it "should return an error if no secret is set" do
    expect {
      subject
    }.to raise_error
  end

  context "secret is set" do
    before :each do
      instance.otp_secret_key = "2z6hxkdwi3uvrnpn"
    end

    it "should not return an error" do
      subject
    end

    it "should be configured length" do
      expect(subject.length).to eq(Devise.otp_length)
    end

    context "with a known time" do
      let(:time) { 1392852756 }

      it "should return a known result" do
        expect(subject).to eq("0000000524562202".split(//).last(Devise.otp_length).join)
      end
    end

    context "with a known time yielding a result with less than 6 digits" do
      let(:time) { 1393065856 }

      it "should return a known result padded with zeroes" do
        expect(subject).to eq("0000001608007672".split(//).last(Devise.otp_length).join)
      end
    end
  end
end

describe Devise::Models::TwoFactorAuthenticatable, '#authenticate_otp' do
  let(:instance) { build_guest_user }

  before :each do
    instance.otp_secret_key = "2z6hxkdwi3uvrnpn"
  end

  def do_invoke code, options = {}
    instance.authenticate_otp(code, options)
  end

  it "should be able to authenticate a recently created code" do
    code = instance.otp_code
    expect(do_invoke(code)).to eq(true)
  end

  it "should not authenticate an old code" do
    code = instance.otp_code(1.minutes.ago.to_i)
    expect(do_invoke(code)).to eq(false)
  end
end

describe Devise::Models::TwoFactorAuthenticatable, '#send_two_factor_authentication_code' do
  let(:instance) { build_guest_user }

  it "should raise an error by default" do
    expect {
      instance.send_two_factor_authentication_code
    }.to raise_error(NotImplementedError)
  end

  it "should be overrideable" do
    def instance.send_two_factor_authentication_code
      "Code sent"
    end
    expect(instance.send_two_factor_authentication_code).to eq("Code sent")
  end
end

describe Devise::Models::TwoFactorAuthenticatable, '#provisioning_uri' do
  let(:instance) { build_guest_user }

  before do
    instance.email = "houdini@example.com"
    instance.run_callbacks :create
  end

  it "should return uri with user's email" do
    expect(instance.provisioning_uri).to match(%r{otpauth://totp/houdini@example.com\?secret=\w{16}})
  end

  it "should return uri with issuer option" do
    expect(instance.provisioning_uri("houdini")).to match(%r{otpauth://totp/houdini\?secret=\w{16}$})
  end

  it "should return uri with issuer option" do
    require 'cgi'

    uri = URI.parse(instance.provisioning_uri("houdini", issuer: 'Magic'))
    params = CGI::parse(uri.query)

    expect(uri.scheme).to eq("otpauth")
    expect(uri.host).to eq("totp")
    expect(uri.path).to eq("/houdini")
    expect(params['issuer'].shift).to eq('Magic')
    expect(params['secret'].shift).to match(%r{\w{16}})
  end
end

describe Devise::Models::TwoFactorAuthenticatable, '#populate_otp_column' do
  let(:instance) { build_guest_user }

  it "populates otp_column on create" do
    expect(instance.otp_secret_key).to be_nil

    instance.run_callbacks :create # populate_otp_column called via before_create

    expect(instance.otp_secret_key).to match(%r{\w{16}})
  end

  it "repopulates otp_column" do
    instance.run_callbacks :create
    original_key = instance.otp_secret_key

    instance.populate_otp_column

    expect(instance.otp_secret_key).to match(%r{\w{16}})
    expect(instance.otp_secret_key).to_not eq(original_key)
  end
end

describe Devise::Models::TwoFactorAuthenticatable, '#max_login_attempts' do
  let(:instance) { build_guest_user }

  before do
    @original_max_login_attempts = GuestUser.max_login_attempts
    GuestUser.max_login_attempts = 3
  end

  after { GuestUser.max_login_attempts = @original_max_login_attempts }

  it "returns class setting" do
    expect(instance.max_login_attempts).to eq(3)
  end

  it "returns false as boolean" do
    instance.second_factor_attempts_count = nil
    expect(instance.max_login_attempts?).to be_falsey
    instance.second_factor_attempts_count = 0
    expect(instance.max_login_attempts?).to be_falsey
    instance.second_factor_attempts_count = 1
    expect(instance.max_login_attempts?).to be_falsey
    instance.second_factor_attempts_count = 2
    expect(instance.max_login_attempts?).to be_falsey
  end

  it "returns true as boolean after too many attempts" do
    instance.second_factor_attempts_count = 3
    expect(instance.max_login_attempts?).to be_truthy
    instance.second_factor_attempts_count = 4
    expect(instance.max_login_attempts?).to be_truthy
  end
end
