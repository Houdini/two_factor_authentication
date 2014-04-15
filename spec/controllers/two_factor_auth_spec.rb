require 'spec_helper'

include Warden::Test::Helpers

describe HomeController do
  context "passed only 1st factor auth" do
    let(:user) { create_user }

    describe "is_fully_authenticated helper" do
      it "should be true" do
        login_as user, scope: :user
        visit user_two_factor_authentication_path


        controller.is_fully_authenticated?.should be_true
      end
    end

  end
end