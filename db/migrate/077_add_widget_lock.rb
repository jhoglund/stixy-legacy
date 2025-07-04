class AddWidgetLock < ActiveRecord::Migration
  def self.up
    add_column "widget_instances", "locked", :integer, :default => 0
  end
  
  def self.down
    remove_column "widget_instances", "locked"
  end
end
