class AlterUserNotification < ActiveRecord::Migration
  def self.up
    rename_table "user_notofications", "user_notifications"
    add_column "user_notifications", "status", :integer, :default => 0, :limit => 4, :null => false   
  end
  
  def self.down
    rename_table "user_notifications", "user_notofications"
    remove_column "user_notifications", "status"
  end
end
