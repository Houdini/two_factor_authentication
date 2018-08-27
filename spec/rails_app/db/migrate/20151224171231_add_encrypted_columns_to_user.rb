class AddEncryptedColumnsToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :encrypted_otp_secret_key, :string
    add_column :users, :encrypted_otp_secret_key_iv, :string
    add_column :users, :encrypted_otp_secret_key_salt, :string

    add_index :users, :encrypted_otp_secret_key, unique: true
  end
end
