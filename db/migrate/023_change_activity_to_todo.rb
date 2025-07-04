class ChangeActivityToTodo < ActiveRecord::Migration
  def self.up
    Widget.find_by_name("Activity").update_attributes(:name => "Todo")
  end            
                 
  def self.down  
    Widget.find_by_name("Todo").update_attributes(:name => "Activity")
  end
end
