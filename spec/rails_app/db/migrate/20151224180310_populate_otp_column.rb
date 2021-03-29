class PopulateOtpColumn < ActiveRecord::Migration[4.2]
  def up
    User.reset_column_information

    User.find_each do |user|
      user.otp_secret_key = user.read_attribute('otp_secret_key')
      user.save!
    end
  end

  def down
    User.reset_column_information

    User.find_each do |user|
      user.otp_secret_key = ROTP::Base32.random_base32
      user.save!
    end
  end
end
