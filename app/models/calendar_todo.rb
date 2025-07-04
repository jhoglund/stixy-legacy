class CalendarTodo < AbstractCalendar
	has_one 	:prio, :class_name => "Priority", :as => :priorable, :dependent => :destroy  
  
  def self.get_for_calendar(user_id, start = Date.today, stop = (start+31), options = {})
		silence do
		  find(:all,  :conditions => ["members.user_id = ? AND (date(activities.start) >= date(?) AND date(activities.start) <= date(?) AND abstract_calendars.status = #{Status::ACTIVE} AND activities.status = #{Status::ACTIVE})", user_id, start, stop],
  							  :include => [:members, :activity, :prio])
	  end
	end

	def self.get_for_global_todolist(user_id)
  	silence do
  	  find(:all,  :conditions => ["members.user_id = ? AND abstract_calendars.status != #{Status::DISABLED}", user_id],
  								:include => [:members, :activity, :prio], :order => "priorities.level desc, activities.start desc")
	  end
	end
  
  def self.clear_completed user_id
    calendar_entries = self.find_by_sql "select abstract_calendars.id from abstract_calendars left join members on abstract_calendars.id = members.membershipable_id 
                                              where members.membershipable_type =  'AbstractCalendar' and abstract_calendars.status = #{Status::FINISHED} and members.user_id = #{user_id};"
		unless calendar_entries.empty?
		  self.connection.update("update abstract_calendars set status=#{Status::DISABLED} where id in (#{calendar_entries.collect{|r| r.id}.join(",")})")
	  end
  end
  
	def priority= value
	  self.prio ||= Priority.new
	  self.prio.level = value
	end
	
	def overdue?
	 duedate < Time.now.getutc
	end

  def priority type=:number
	  level = (self.prio.nil? or self.prio.level.nil?) ? Priority::LOW : self.prio.level
    if type.to_sym == :name
      Priority::PRIORITY_NAMES[level].titlecase 
    else
      level
    end
  end
  
  def duedate_state= value
		self.activity ||= Activity.new
		self.activity.status = (value.to_i == 0 ? Status::DISABLED : Status::ACTIVE)
  end
  
  def duedate_state
    if self.activity
		  self.activity.status==Status::ACTIVE
	  end
  end
  alias :duedate? duedate_state
  
	def duedate= *value
		self.activity = Activity.new unless self.activity
		if self.activity.status == Status::ACTIVE
		  self.activity.start = parse_time(*value)
		  self.activity.stop = self.activity.start
	  end
	end
	alias :start= :duedate=
	def stop= *value; end

	def duedate
		self.activity.start rescue Activity.new(:start => Time.now).start
	end
	alias :start :duedate
	alias :stop :duedate

	def completed= value
		self.status = (value.to_i == 1 ? Status::FINISHED : Status::ACTIVE)
		if self.notification
	    self.notification.update_attribute(:status, (value.to_i == 1 ? Status::FINISHED : Status::PENDING))
    end
	end

	def completed
	  self.status
  end
	
	def completed?
	  self.status == Status::FINISHED
  end
  
	def todo_text
		calendar_text
	end
	alias :text :calendar_text
  
  def description
    self.note
  end
  
  after_save do |record|
    record.prio.save if record.prio
  end

end
