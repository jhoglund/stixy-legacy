class AlterWidgetStylesTable < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `widget_instance_styles` CHANGE `attribute` `attr` varchar(50) NOT NULL DEFAULT '';"
  end
  
  def self.down
    execute "ALTER TABLE `widget_instance_styles` CHANGE `attr` `attribute` varchar(50) NOT NULL DEFAULT '';"
  end
end
