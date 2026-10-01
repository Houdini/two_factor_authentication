class AddOtpColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :otp_secret_key, :string
    add_column :users, :direct_otp, :string
    add_column :users, :direct_otp_sent_at, :datetime
    add_column :users, :totp_timestamp, :timestamp
  end
end
