class TwoFactorAuthenticationAddTo<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    change_table :<%= table_name %> do |t|
      t.string   :otp_secret_key
      t.integer  :second_factor_attempts_count, :default => 0
    end
  end
end
