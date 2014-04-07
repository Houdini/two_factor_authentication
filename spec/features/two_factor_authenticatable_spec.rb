require 'spec_helper'

feature "User of two factor authentication" do

  scenario "must be logged in" do
    visit user_two_factor_authentication_path

    expect(page).to have_content("Welcome Home")
    expect(page).to have_content("You are signed out")
  end

  context "when logged in" do
    let(:user) { create_user }

    background do
      login_as user
    end

    scenario "can fill in TFA code" do
      visit user_two_factor_authentication_path

      expect(page).to have_content("You are signed in as Marissa")
      expect(page).to have_content("Enter your personal code")

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
      expect(page).to have_content("You are signed in as Marissa")
    end

    scenario "is locked out after 3 failed attempts" do
      visit user_two_factor_authentication_path

      3.times do
        fill_in "code", with: "incorrect#{rand(100)}"
        click_button "Submit"

        within(".flash.error") do
          expect(page).to have_content("Attempt failed")
        end
      end

      expect(page).to have_content("Access completely denied")
      expect(page).to have_content("You are signed out")
    end
  end
end
