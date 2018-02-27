class AddParanoidModeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :enable_2fa_paranoid_mode, :boolean, default: false
  end
end
