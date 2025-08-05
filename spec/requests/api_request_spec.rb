require 'spec_helper'

describe "API request", type: :request do
  context "when logged in" do
    let(:user) { create_user("encrypted", email: "foo@example.com", otp_secret_key: "6iispf5cjufa4vsm") }

    before do
      sign_in user
    end

    context "with json" do
      context "with totp authentication" do
        it "returns 401 when path requires authentication" do
          get "/dashboard.json"
          expect(response.response_code).to eq(401)
          body = JSON.parse(response.body)
          expect(body["redirect_to"]).to eq(user_two_factor_authentication_path)
          expect(body["authentication_type"]).to eq("totp")
        end
      end

      context "with direct otp authentication" do
        it "returns 401 when path requires authentication" do
          user.update!(direct_otp: true)
          get "/dashboard.json"
          expect(response.response_code).to eq(401)
          body = JSON.parse(response.body)
          expect(body["redirect_to"]).to eq(user_two_factor_authentication_path)
          expect(body["authentication_type"]).to eq("otp")
        end
      end

      context "after TFA" do
        it "returns successfully" do
          get "/dashboard.json"
          expect(response.response_code).to eq(401)
          expect(JSON.parse(response.body)["redirect_to"]).to eq(user_two_factor_authentication_path)
          totp_code = ROTP::TOTP.new(user.otp_secret_key, digits: 6).at(Time.now)
          put "/users/two_factor_authentication", params: { code: totp_code }
          get "/dashboard.json"
          expect(response.response_code).to eq(200)
          body = JSON.parse(response.body)
          expect(body["success"]).to eq(true)
        end
      end
    end

    context "with xml" do
      it "returns 401 when path requires authentication" do
        get "/dashboard.xml"
        expect(response.response_code).to eq(401)
      end

      context "after TFA" do
        it "returns successfully" do
          totp_code = ROTP::TOTP.new(user.otp_secret_key, digits: 6).at(Time.now)
          put "/users/two_factor_authentication", params: { code: totp_code }
          get "/dashboard.xml"
          expect(response.response_code).to eq(200)
          expect(response.body).to eq("<success></success>")
        end
      end
    end
  end
end