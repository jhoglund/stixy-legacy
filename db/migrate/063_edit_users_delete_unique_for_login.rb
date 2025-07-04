class EditUsersDeleteUniqueForLogin < ActiveRecord::Migration
  def self.up
		remove_index :users, :name => "users_login_index"
  end

  def self.down
		add_index "users", ["login"], :name => "users_login_index", :unique => true
  end
end
