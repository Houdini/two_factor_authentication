# A second 2FA scope whose TOTP secret is encrypted.
class DeviseCreateSecureUsers < ActiveRecord::Migration[7.2]
  def change
    create_table(:secure_users) do |t|
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      t.integer  :second_factor_attempts_count, default: 0
      t.string   :encrypted_otp_secret_key
      t.string   :encrypted_otp_secret_key_iv
      t.string   :encrypted_otp_secret_key_salt
      t.string   :direct_otp
      t.datetime :direct_otp_sent_at
      t.timestamp :totp_timestamp

      t.timestamps null: false
    end

    add_index :secure_users, :email, unique: true
    add_index :secure_users, :encrypted_otp_secret_key, unique: true
  end
end
