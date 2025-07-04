class AddUserTimeOffset < ActiveRecord::Migration
  def self.up
    add_column "users", "time_offset", :integer, :limit => 4, :default => 0, :null => false
    add_column "users", "time_zone", :integer, :limit => 4, :default => 0, :null => false
  end
  
  def self.down
    remove_column "users", "time_offset"
    remove_column "users", "time_zone"
  end
end
