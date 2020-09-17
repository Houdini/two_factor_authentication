class TwoFactorAuthenticationAddTo<%= table_name.camelize %> < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_column :<%= table_name %>, :second_factor_attempts_count, :integer, default: 0
    add_column :<%= table_name %>, :encrypted_otp_secret_key, :string
    add_column :<%= table_name %>, :encrypted_otp_secret_key_iv, :string
    add_column :<%= table_name %>, :encrypted_otp_secret_key_salt, :string
    add_column :<%= table_name %>, :direct_otp, :string
    add_column :<%= table_name %>, :direct_otp_sent_at, :datetime
    add_column :<%= table_name %>, :totp_timestamp, :timestamp

    add_index :<%= table_name %>, :encrypted_otp_secret_key, unique: true, algorithm: :concurrently
  end
end
