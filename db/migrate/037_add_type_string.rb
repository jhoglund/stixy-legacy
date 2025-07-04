class AddTypeString < ActiveRecord::Migration
  def self.up
    WidgetInstance.find(:all).each do |instance| 
      instance.type = "Widget#{Widget.find(instance.widget_id).name}"
      instance.save
    end
  end
end
