class CreateWidgetActivity < ActiveRecord::Migration
  def self.up
    create_table "widget_instance_activities", :options => "TYPE=MyISAM" do |t|
      t.column "widget_instance_id", :integer, :null => false
      t.column "time", :datetime, :null => false
      t.column "created_by_id", :integer, :default => 1, :null => false
      t.column "updated_by_id", :integer, :default => 1, :null => false
      t.column "created_on", :datetime, :null => false
      t.column "updated_on", :datetime, :null => false
    end
    create_table "activity_notification", :options => "TYPE=MyISAM" do |t|
      t.column "widget_instance_id", :integer, :null => false
      t.column "time", :datetime, :null => false
      t.column "created_by_id", :integer, :default => 1, :null => false
      t.column "updated_by_id", :integer, :default => 1, :null => false
      t.column "created_on", :datetime, :null => false
      t.column "updated_on", :datetime, :null => false
    end
    create_table "activity_notification_users", :options => "TYPE=MyISAM" do |t|
      t.column "widget_notification_id", :integer, :null => false
      t.column "widget_user_id", :integer, :null => false
    end
  end
  
  def self.down
    drop_table "widget_instance_activities"
    drop_table "activity_notification"
    drop_table "activity_notification_users"
  end
end
