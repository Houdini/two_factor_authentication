class RemoveOtpSecretKeyFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :otp_secret_key, :string
  end
end
