require 'spec_helper'

feature "User of two factor authentication" do
  let(:user) { create_user }

  scenario "must be logged in" do
    visit user_two_factor_authentication_path

    expect(page).to have_content("Welcome Home")
    expect(page).to have_content("You are signed out")
  end

  scenario "sends two factor authentication code after sign in" do
    expect(SMSProvider.messages).to be_empty

    visit new_user_session_path
    complete_sign_in_form_for(user)

    expect(page).to have_content "Enter your personal code"

    expect(SMSProvider.messages.size).to eq(1)
    message = SMSProvider.last_message
    expect(message.to).to eq(user.phone_number)
    expect(message.body).to eq(user.otp_code)
  end

  context "when logged in" do

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
      visit dashboard_path + "?A=param%20a&B=param%20b"

      expect(page).to_not have_content("Your Personal Dashboard")

      fill_in "code", with: user.otp_code
      click_button "Submit"

      expect(page).to have_content("Your Personal Dashboard")
      expect(page).to have_content("You are signed in as Marissa")
      expect(page).to have_content("Param A is param a")
      expect(page).to have_content("Param B is param b")
    end

    scenario "is locked out after max failed attempts" do
      visit user_two_factor_authentication_path

      max_attempts = User.max_login_attempts

      max_attempts.times do
        fill_in "code", with: "incorrect#{rand(100)}"
        click_button "Submit"

        within(".flash.error") do
          expect(page).to have_content("Attempt failed")
        end
      end

      expect(page).to have_content("Access completely denied")
      expect(page).to have_content("You are signed out")
    end

    scenario "cannot retry authentication after max attempts" do
      user.update_attribute(:second_factor_attempts_count, User.max_login_attempts)

      visit user_two_factor_authentication_path

      expect(page).to have_content("Access completely denied")
      expect(page).to have_content("You are signed out")
    end

    describe "rememberable TFA" do
      before do
        @original_remember_otp_session_for_seconds = User.remember_otp_session_for_seconds
        User.remember_otp_session_for_seconds = 30.days
      end

      after do
        User.remember_otp_session_for_seconds = @original_remember_otp_session_for_seconds
      end

      scenario "doesn't require TFA code again within 30 days" do
        visit user_two_factor_authentication_path
        fill_in "code", with: user.otp_code
        click_button "Submit"

        logout

        login_as user
        visit dashboard_path
        expect(page).to have_content("Your Personal Dashboard")
        expect(page).to have_content("You are signed in as Marissa")
      end

      scenario "requires TFA code again after 30 days" do
        visit user_two_factor_authentication_path
        fill_in "code", with: user.otp_code
        click_button "Submit"

        logout

        Timecop.travel(30.days.from_now)
        login_as user
        visit dashboard_path
        expect(page).to have_content("You are signed in as Marissa")
        expect(page).to have_content("Enter your personal code")
      end
    end
  end

  describe 'signing in' do
    scenario 'when UserOtpSender#reset_otp_state is defined' do
      stub_const 'UserOtpSender', Class.new

      otp_sender = instance_double(UserOtpSender)
      expect(UserOtpSender).to receive(:new).with(user).and_return(otp_sender)
      expect(otp_sender).to receive(:reset_otp_state)

      visit new_user_session_path
      complete_sign_in_form_for(user)
    end

    scenario 'when UserOtpSender#reset_otp_state is not defined' do
      stub_const 'UserOtpSender', Class.new

      otp_sender = instance_double(UserOtpSender)
      allow(otp_sender).to receive(:respond_to?).with(:reset_otp_state).and_return(false)

      expect(UserOtpSender).to receive(:new).with(user).and_return(otp_sender)
      expect(otp_sender).to_not receive(:reset_otp_state)

      visit new_user_session_path
      complete_sign_in_form_for(user)
    end
  end

  describe 'signing out' do
    scenario 'when UserOtpSender#reset_otp_state is defined' do
      visit new_user_session_path
      complete_sign_in_form_for(user)

      stub_const 'UserOtpSender', Class.new
      otp_sender = instance_double(UserOtpSender)

      expect(UserOtpSender).to receive(:new).with(user).and_return(otp_sender)
      expect(otp_sender).to receive(:reset_otp_state)

      visit destroy_user_session_path
    end

    scenario 'when UserOtpSender#reset_otp_state is not defined' do
      visit new_user_session_path
      complete_sign_in_form_for(user)

      stub_const 'UserOtpSender', Class.new
      otp_sender = instance_double(UserOtpSender)
      allow(otp_sender).to receive(:respond_to?).with(:reset_otp_state).and_return(false)

      expect(UserOtpSender).to receive(:new).with(user).and_return(otp_sender)
      expect(otp_sender).to_not receive(:reset_otp_state)

      visit destroy_user_session_path
    end
  end
end
