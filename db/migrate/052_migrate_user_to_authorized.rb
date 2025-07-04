class MigrateUserToAuthorized < ActiveRecord::Migration
  def self.up
    unless User.public_method_defined? :salt
      add_column :users, :crypted_password,          :string, :limit => 40
      add_column :users, :salt,                      :string, :limit => 40
      add_column :users, :remember_token,            :string
      add_column :users, :remember_token_expires_at, :datetime
      User.find(:all).each do |u|
        u.crypted_password = u.pwd
        u.save_without_validation
      end
      execute "UPDATE `users` SET `salt`='yo-ma-salt'"
    end
    #remove_column :users, :pwd
  end

  def self.down
    #add_column :users, :pwd, :string, :limit => 60, :null => false
    User.find(:all).each do |u|
      u.pwd = u.crypted_password
      u.save_without_validation
    end
    remove_column :users, :crypted_password
    remove_column :users, :salt
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
  end
end