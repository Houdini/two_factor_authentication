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