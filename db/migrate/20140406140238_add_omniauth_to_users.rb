class AddOmniauthToUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string, default: nil
    add_column :users, :url, :string, index: true, default: nil
    change_column :users, :email, :string, null: true, unique: false
    add_index :users, [:provider, :email, :url], unique: true
  end
end
