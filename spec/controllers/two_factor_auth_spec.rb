require 'spec_helper'

include Warden::Test::Helpers

describe HomeController, :type => :controller do
  context "passed only 1st factor auth" do
    let(:user) { create_user }

    describe "is_fully_authenticated helper" do
      it "should be true" do
        login_as user, scope: :user
        visit user_two_factor_authentication_path

        expect(controller.is_fully_authenticated?).to be_truthy
      end
    end
  end
end
