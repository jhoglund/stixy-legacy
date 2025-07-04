class WidgetIndex < ActiveRecord::Migration
  def self.up
    add_index :widget_instances, [:widget_name, :board_id, :widget_id]
    add_index :widget_instance_activities, [:time, :widget_instance_id]
    add_index :widget_instance_texts, [:name, :widget_instance_id], :name => :w_text_name
    add_index :widget_instance_styles, [:attr, :name,:widget_instance_id], :name => :w_style_name
  end
  
  def self.down
    remove_index :widget_instances, [:widget_name, :board_id, :widget_id]
    remove_index :widget_instance_activities, [:time, :widget_instance_id]
    remove_index :widget_instance_texts, [:name, :widget_instance_id]
    remove_index :widget_instance_styles, [:attr, :name,:widget_instance_id]
  end
end
