class TwoFactorAuthenticationAddTo<%= table_name.camelize %> < ActiveRecord::Migration
  def up
    change_table :<%= table_name %> do |t|
      t.string   :otp_secret_key
      t.integer  :second_factor_attempts_count, :default => 0
    end

    add_index :<%= table_name %>, :otp_secret_key, :unique => true
  end

  def down
    remove_column :<%= table_name %>, :otp_secret_key
    remove_column :<%= table_name %>, :second_factor_attempts_count
  end
end
