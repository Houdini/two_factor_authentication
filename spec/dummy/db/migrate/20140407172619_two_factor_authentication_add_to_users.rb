class TwoFactorAuthenticationAddToUsers < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.string   :otp_secret_key
      t.integer  :second_factor_attempts_count, :default => 0
    end

    add_index :users, :otp_secret_key, :unique => true
  end

  def down
    remove_column :users, :otp_secret_key
    remove_column :users, :second_factor_attempts_count
  end
end
