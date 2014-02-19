require 'spec_helper'
include AuthenticatedModelHelper


describe Devise::Models::TwoFactorAuthenticatable, '#otp_code' do
  let(:instance) { AuthenticatedModelHelper.create_new_user }
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

    context "with a known time" do
      let(:time) { 1392852756 }

      it "should return a known result" do
        expect(subject).to eq(562202)
      end
    end
  end
end

describe Devise::Models::TwoFactorAuthenticatable, '#authenticate_otp' do
  let(:instance) { AuthenticatedModelHelper.create_new_user }

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