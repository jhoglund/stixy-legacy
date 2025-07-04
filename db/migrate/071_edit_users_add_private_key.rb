class EditUsersAddPrivateKey < ActiveRecord::Migration
  def self.up
    add_column :users, :private_key, :string
  end

  def self.down
    remove_column :users, :private_key
  end
end
