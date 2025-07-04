class AddTypeToWidgetInstances < ActiveRecord::Migration
  def self.up
    add_column "widget_instances", "type", :string, :default => ""
  end
  
  def self.down
    remove_column "widget_instances", "type"
  end
end
