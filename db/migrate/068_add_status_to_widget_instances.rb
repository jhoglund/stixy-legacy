class AddStatusToWidgetInstances < ActiveRecord::Migration
  def self.up
    add_column :widget_instances, :status, :integer, :limit => 4, :default => 1, :null => false
  end

  def self.down
    remove_column :widget_instances, :status
  end
end
