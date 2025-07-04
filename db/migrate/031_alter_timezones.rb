class AlterTimezones < ActiveRecord::Migration
  def self.up
    remove_column "users", "time_zone"
    change_column "users", "time_offset", :float, :limit => 4, :default => 0, :null => false
  end            
                 
  def self.down  
    change_column "users", "time_offset", :integer, :limit => 4, :default => 0, :null => false
    add_column "users", "time_zone", :integer, :limit => 4, :default => 0, :null => false
  end
end
