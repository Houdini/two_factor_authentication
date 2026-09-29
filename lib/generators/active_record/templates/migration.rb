class TwoFactorAuthenticationAddTo<%= table_name.camelize %> < ActiveRecord::Migration<%= migration_version %>
<% if postgresql? -%>
  disable_ddl_transaction!

<% end -%>
  def change
    add_column :<%= table_name %>, :second_factor_attempts_count, :integer, default: 0
    add_column :<%= table_name %>, :encrypted_otp_secret_key, :string
    add_column :<%= table_name %>, :encrypted_otp_secret_key_iv, :string
    add_column :<%= table_name %>, :encrypted_otp_secret_key_salt, :string
    add_column :<%= table_name %>, :direct_otp, :string
    add_column :<%= table_name %>, :direct_otp_sent_at, :datetime
    add_column :<%= table_name %>, :totp_timestamp, :timestamp

<% if postgresql? -%>
    add_index :<%= table_name %>, :encrypted_otp_secret_key, unique: true, algorithm: :concurrently
<% else -%>
    add_index :<%= table_name %>, :encrypted_otp_secret_key, unique: true
<% end -%>
  end
end
