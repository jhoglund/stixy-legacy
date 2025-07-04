class WidgetTodolist < WidgetInstance
#	acts_as_tree
	
#	has_one 		:activity, :as => :activatable, :dependent => :destroy
  has_one     :widget_instance_text, :dependent => :destroy, :foreign_key => "widget_instance_id"

#  has_many 		:text, :class_name => "WidgetInstanceText", :dependent => :destroy, :foreign_key => "widget_instance_id"

#	has_one 		:priority, :as => :priorable, :dependent => :destroy
  has_many    :styles, :class_name => "WidgetInstanceStyle", :dependent => :destroy, :foreign_key => "widget_instance_id"
	has_many 		:members, :class_name => "WidgetMember", :foreign_key => "widget_instance_id"


#  has_many    :reminders, :class_name => "UserNotification", :dependent => :destroy, :foreign_key => "widget_instance_id",:conditions => "status=2"
#  has_many    :user_notifications, :dependent => :destroy
  belongs_to  :widget


  class << self
    def get(board_id)
      find(:all, :conditions => "widget_name = 'WidgetTodolist' and board_id = #{board_id}", :include => [:widget, :widget_instance_text, :styles])
    end
    def eager_find(*args)
      options = get_find_options(args)
      options[:include] = [options[:include],[ :styles, :widget_instance_text]].flatten.compact
      find(args[0], options)
    end   
  end
  
  def initialize p=nil
    super(p)
 #   self.time = self.class.rounded_time(Time.now+(60*60*24))
    self.widget_id = 5
  end
  

  def instance_attributes stay
    rem = self.reminders
    str = (stay==1) ? "stay:1" : ""
    return "" if rem.size == 0
    str += ", " unless str.empty?
    return "#{str}remind:true, remindAt:#{self.reminder_offset}, remindAll: #{rem.select{|r| r.user_id==0}.size > 0 }, remindOnly:[#{rem.delete_if{|r| r.user_id == 0 }.collect{|r| r.user_id}.join(",")}]"
  end


#  def time
#    self.activity.start rescue self.rounded_time
#  end
#  alias :start :time
#	alias :stop :time
  

#  def time= value
#    self.activity = Activity.create(:start => value)
#  end


  def text
    widget_instance_text.value rescue "<font></font>"
  end
  

  def text= value
    self.widget_instance_text = WidgetInstanceText.new(:value => value)
  end


#  def rounded_time time=Time.now
#		return time - (time.min * 60) - time.sec
#	end

	
#  def self.rounded_time time=Time.now
#		return time - (time.min * 60) - time.sec
#	end
    

#	def self.get_for_calendar(user_id, start = Date.today, stop = start+31)
#			WidgetTodo.find_by_sql ["SELECT a.id AS 'activity_id', a.start, a.stop, wi.board_id, wi.id AS 'id' FROM widget_instances AS wi 
#															LEFT JOIN activities AS a ON wi.id = a.activatable_id AND a.activatable_type = 'WidgetInstance'
#															LEFT JOIN boardusers AS bu ON bu.board_id = wi.board_id
#															WHERE
#															((date(a.start) >= ? AND date(a.start) < ?) OR (date(a.stop) >= ? AND date(a.stop) < ?))
#															AND bu.user_id = ?",  start, stop, start, stop, user_id]
#	end




end
