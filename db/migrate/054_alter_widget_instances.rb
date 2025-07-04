class AlterWidgetInstances < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `widget_instances` CHANGE `type` `widget_name` varchar(32) DEFAULT '';"
  end
  
  def self.down
    execute "ALTER TABLE `widget_instances` CHANGE `widget_name` `type` varchar(255) DEFAULT '';"
  end
end
