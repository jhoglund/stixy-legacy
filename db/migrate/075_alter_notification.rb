class AlterNotification < ActiveRecord::Migration
  def self.up
    add_column :notifications, :unit, :integer, :limit => 4, :default => Notification::HOUR
    add_column :notifications, :value, :integer, :limit => 4, :default => 1
	end

  def self.down
		remove_column :notifications, :unit 
		remove_column :notifications, :value
  end
end
