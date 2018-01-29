class RemoveOtpSecretKeyFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :otp_secret_key, :string
  end
end
