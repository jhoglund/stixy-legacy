class WidgetTodo < WidgetInstance
#  has_one     :activity,  :class_name => "WidgetInstanceActivity",  :dependent => :destroy, :foreign_key => "widget_instance_id"     
	has_one 		:activity, :as => :activatable
  has_one     :widget_instance_text, :dependent => :destroy, :foreign_key => "widget_instance_id"
  has_many    :styles, :class_name => "WidgetInstanceStyle", :dependent => :destroy, :foreign_key => "widget_instance_id"
  has_many    :reminders, :class_name => "UserNotification", :dependent => :destroy, :foreign_key => "widget_instance_id",:conditions => "user_notifications.status=2"
  has_many    :user_notifications, :dependent => :destroy
  belongs_to  :widget

 
  class << self
    def get(board_id, status=Status::ACTIVE)
      find(:all, :conditions => "widget_name = 'WidgetTodo' and board_id = #{board_id} and widget_instances.status = #{status}", :include => [:widget, :activity, :widget_instance_text, :styles, :reminders])
    end
    def eager_find(*args)
      options = get_find_options(args)
      options[:include] = [options[:include],[:reminders, :styles, :activity, :widget_instance_text]].flatten.compact
      find(args[0], options)
    end 
    
    def rounded_time time=Time.now
  		return time - (time.min * 60) - time.sec
  	end

  	def get_for_calendar(user_id, start = Date.today, stop = start+31, options = {})
  			WidgetTodo.find_by_sql ["SELECT a.id AS 'activity_id', a.start, a.stop, wi.board_id, wi.id AS 'id'
  															FROM widget_instances AS wi 
  															LEFT JOIN activities AS a ON wi.id = a.activatable_id AND a.activatable_type = 'WidgetInstance'
  															LEFT JOIN boardusers AS bu ON bu.board_id = wi.board_id
  															WHERE
  															((date(a.start) >= date(?) AND date(a.start) < date(?)) OR (date(a.stop) >= date(?) AND date(a.stop) < date(?)))
  															AND bu.user_id = ? AND wi.status = ?",  start, stop, start, stop, user_id, Status::ACTIVE]
  	end
     
  end
  
  def initialize p=nil
    super(p)
    self.activity ||=  Activity.new
    self.activity.start = self.class.rounded_time(Time.now+(60*60*24))
    self.widget_id = 4
  end
  
  def instance_attributes *att
    rem = self.reminders
    str = super(*att)
    return str if rem.size == 0
    return "#{str}, remind:true, remindAt:#{self.reminder_offset}, remindAll: #{rem.select{|r| r.user_id==0}.size > 0 }, remindOnly:[#{rem.delete_if{|r| r.user_id == 0 }.collect{|r| r.user_id}.join(",")}]"
  end
  
  def reminder_offset
    return (time.to_f - reminders.first.time.to_f) / 3600
  end
  
  def time
    self.activity.start rescue self.rounded_time
  end
  alias :start :time
	alias :stop :time
  
  def time= value
    self.activity ||=  Activity.new
    self.activity.update_attributes!(:start => value)
  end
  
  def comment
    (self.widget_instance_text || WidgetInstanceText.new).value
  end
  alias :text :comment
  
  def calendar_text
    text = comment
    text.gsub!(/<.*?>/, "")
    return text unless text.empty?
    return "Untitled" + (board.title.empty? ? "" : " (#{board.title})")
  end
  alias :description :calendar_text
  
  def comment= text
    self.widget_instance_text ||=  WidgetInstanceText.new(:value => text[:value])
    self.widget_instance_text.update_attributes!(:value => text[:value])
  end
  alias :text= :comment=
  
  def style= params=[]
    unless params.nil?
      params.each do |key,value|
        self.styles.find_or_create_by_name_and_attr(value[:name],key, :select => :value).update_attribute(:value,value[:value]||value)
      end
    end
  end
  
  def copy *args
    widget = clone
    widget.widget_instance_text = widget_instance_text.clone
    widget.activity = activity.clone
    styles.each do |style|
      widget.styles << style.clone
    end
    unless args.include?(:no_reminders)
      reminders.each do |reminder|
        widget.reminders << reminder.clone
      end
    end
    widget.save
    return widget
  end
  
  
  def rounded_time time=Time.now
		return time - (time.min * 60) - time.sec
	end
	  
  private

  def before_disable
    self.activity.status = Status::DISABLED
    self.activity.save!
  end
  
  def after_enable
    self.activity.status = Status::ACTIVE
    self.activity.save!
  end
  

#  def after_create
#    self.activity.users = self.board.users
#  end
  
end
