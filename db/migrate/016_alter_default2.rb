class AlterDefault2 < ActiveRecord::Migration
  def self.up
    change_column "widget_instance_styles", "name", :string, :limit => 50, :default => "NULL"
    change_column "widget_instance_texts", "name", :string, :limit => 50, :default => "NULL"
  end            
                 
  def self.down  
    change_column "widget_instance_styles", "name", :string, :limit => 50
    change_column "widget_instance_texts", "name", :string, :limit => 50
  end
end
