class AddEnableOtpToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :otp_enabled, :boolean, default: false
  end
end
