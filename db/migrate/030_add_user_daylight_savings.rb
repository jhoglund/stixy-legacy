class AddUserDaylightSavings < ActiveRecord::Migration
  def self.up
    add_column "users", "daylight_savings", :integer, :limit => 4, :default => 0, :null => false
  end
  
  def self.down
    remove_column "users", "daylight_savings"
  end
end
