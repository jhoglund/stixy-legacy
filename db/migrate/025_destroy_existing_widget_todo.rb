class DestroyExistingWidgetTodo < ActiveRecord::Migration
  def self.up
    WidgetInstance.find_all_by_widget_id(4).each{|w| w.destroy }
  end
end
