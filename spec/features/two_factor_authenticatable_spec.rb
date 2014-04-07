require 'spec_helper'

feature "User of two factor authentication" do

  scenario "must be logged in" do
    visit user_two_factor_authentication_path

    page.should have_content("Welcome Home")
  end

  context "when logged in" do
    let(:user) { create_user }

    background do
      login_as user
    end

    scenario "can fill in TFA code" do
      visit user_two_factor_authentication_path

      page.should have_content("Enter your personal code")

      fill_in "code", with: user.otp_code
      click_button "Submit"

      within(".flash.notice") do
        expect(page).to have_content("Two factor authentication successful.")
      end
    end

    scenario "is redirected to TFA when path requires authentication" do
      visit dashboard_path

      expect(page).to_not have_content("Your Personal Dashboard")

      fill_in "code", with: user.otp_code
      click_button "Submit"

      expect(page).to have_content("Your Personal Dashboard")
    end
  end
end
