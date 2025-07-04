class WidgetInstanceActivity < ActiveRecord::Base

  belongs_to :widget_instance
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by_id"
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by_id"
  

  def self.get_for_calendar(user_id, start = Time.now, stop = Date.new(start.to_i)+1.month )
#    conditions = if stop
#      "DATE(wa.time) >= DATE('#{start}') AND DATE(wa.time) < DATE('#{stop}')"
#    else
#      "MONTH(wa.time) = MONTH('#{start}') AND YEAR(wa.time) = YEAR('#{start}')"
#    end
    activities = find_by_sql [
      "SELECT wa.id, wa.time, wa.widget_instance_id, wi.board_id, wi.widget_name FROM widget_instances AS wi 
      LEFT JOIN widget_instance_activities AS wa ON wi.id = wa.widget_instance_id
      LEFT JOIN boardusers AS bbu ON bbu.board_id = wi.board_id
      WHERE  DATE(wa.time) >= ?
			AND DATE(wa.time) < ?
			AND bbu.user_id = ?", start, stop, user_id]
    widgets = []
    activities.each do |a|
      widgets << Object.const_get(a.widget_name).find(a.widget_instance_id, :include => [:widget_instance_text, :activity])
    end
    return widgets
  end

  
  def widget_instance
    Object.const_get(WidgetInstance.find(widget_instance_id, :select => "widget_name").widget_name).find(widget_instance_id, :include => [:activity, :widget_instance_text])
  end


  private

  def before_create
    self.created_by = updated_by
  end
  
end
