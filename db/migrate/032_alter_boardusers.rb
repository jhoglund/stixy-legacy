class AlterBoardusers < ActiveRecord::Migration
  def self.up
    add_column "boardusers", "visited_on", :datetime, :null => false
    remove_column "boardusers", "updated_by_id"
  end
  
  def self.down
    remove_column "boardusers", "visited_on", :datetime, :null => false
    add_column "boardusers", "updated_by_id"
  end
end
