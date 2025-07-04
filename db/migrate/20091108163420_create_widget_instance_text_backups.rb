class CreateWidgetInstanceTextBackups < ActiveRecord::Migration
  def self.up
    create_table :widget_instance_text_backups do |t|
      t.text    "value",              :limit => 16777215,                     :null => false
      t.string  "name",               :limit => 50,       :default => "NULL"
      t.integer "widget_instance_id", :limit => 11
      t.timestamps
    end
  end

  def self.down
    drop_table :widget_instance_text_backups
  end
end
