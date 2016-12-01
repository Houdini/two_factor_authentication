class AddEnableOtpToUser < ActiveRecord::Migration
  def change
    add_column :users, :otp_enabled, :boolean, default: false
  end
end
