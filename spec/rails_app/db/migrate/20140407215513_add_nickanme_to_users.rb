class AddNickanmeToUsers < ActiveRecord::Migration[4.2]
  def change
    change_table :users do |t|
      t.column :nickname, :string, limit: 64
    end
  end
end
