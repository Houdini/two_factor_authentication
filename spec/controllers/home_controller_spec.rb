require 'spec_helper'
include AuthenticatedModelHelper
include ControllerHelper

RSpec.describe HomeController, type: :controller do
  context "when logged in" do
    let(:user) { create_user("encrypted", email: "foo@example.com") }

    before do
      sign_in user
    end

    context "with json" do
      it "returns 401 when path requires authentication" do
        warden.session(:user)[TwoFactorAuthentication::NEED_AUTHENTICATION] = true
        get :dashboard, format: "json"
        expect(response.response_code).to eq(401)
      end

      context "after TFA" do
        it "returns successfully" do
          warden.session(:user)[TwoFactorAuthentication::NEED_AUTHENTICATION] = false
          get :dashboard, format: "json"
          expect(response.response_code).to eq(200)
          body = JSON.parse(response.body)
          expect(body["success"]).to eq(true)
        end
      end
    end

    context "with xml" do
      it "returns 401 when path requires authentication" do
        warden.session(:user)[TwoFactorAuthentication::NEED_AUTHENTICATION] = true
        get :dashboard, format: "xml"
        expect(response.response_code).to eq(401)
      end

      context "after TFA" do
        it "returns successfully" do
          warden.session(:user)[TwoFactorAuthentication::NEED_AUTHENTICATION] = false
          get :dashboard, format: "xml"
          expect(response.response_code).to eq(200)
          expect(response.body).to eq("<success></success>")
        end
      end
    end
  end
end