class CalendarEntry < AbstractCalendar
  
  attr_accessor :location_status
  
	def self.get_for_calendar(user_id, start = Date.today, stop = start+31, options = {})
		silence do
		  condition = "members.user_id = ? AND
										((date(activities.stop) >= date(?) AND date(activities.start) <= date(?)) OR
                    (date(activities.start) < date(?) AND date(activities.stop)  >= date(?)) OR
                    (date(activities.stop)  > date(?) AND date(activities.start) <= date(?)))"
      condition << " AND activities.recurring_status = #{Activity::RECURRING_FALSE}" if options[:build_recurring] == true
      condition << " AND abstract_calendars.status = #{Status::ACTIVE}"
		  e1 = find(:all, :conditions => [condition, user_id, start, stop, start, start, stop, stop],
										:include => [:members, :activity], :order => "activities.start asc ")
		  e2 = (options[:build_recurring] == true) ? get_recurring(user_id, start, stop) : []
  		e = e1 + e2
  		return e
  	end
	end
	
	def self.get_recurring(user_id, range_start = Date.today, range_stop = range_start+31)
	  silence do
	    calenderEntries = find(:all,  :conditions => ["members.user_id = ? AND activities.recurring_status = #{Activity::RECURRING_TRUE} AND abstract_calendars.status = #{Status::ACTIVE}", user_id],
															      :include => [:members, :activity])
      activities = []
  		calenderEntries.each do |ce|
        entry_start = ce.activity.start.to_d
        ce.activity.recurrencies(range_start, range_stop) do |activity|
          clone = ce.clone
          clone.activity = activity
          clone.id = ce.id      
          activities << clone
        end
  		end
      return activities
	  end
	end

	def start= *value
		self.activity ||= Activity.new
		self.activity.start = parse_time(*value)
	end

	def start(recurring=false)
		if recurring==true
	    self.activity.first_recurrence
    else
      self.activity.start
    end
  rescue
    nil
	end

	def stop= *value
		self.activity ||= Activity.new
		self.activity.stop = parse_time(*value)
	end

	def stop(recurring=false)
		if recurring==true
	   self.activity.first_recurrence + self.activity.duration
    else
      self.activity.stop
    end
  rescue
    nil
	end
  
	def recurring= value={}
    self.activity ||= Activity.new
    self.activity.recurring_status = value[:status] || 0
    if value[:status].to_s == "1"
      self.activity.unit = value[:unit]
      self.activity.frequency = value[:frequency]
    end
  end

  def recurring?
    self.activity and self.activity.recurring?
  end

  def description
    self.note
  end
  
  def set_notification
    note = super
    if (self.recurring? and note and note.status == Status::PENDING)
      note.status = Status::PENDING_RECURRING
      #note.time = note.offset_time(self.activity.first_recurrence(Time.now))
      note.save
    end
  end

  def after_notification_delivered note=nil
    if note and self.activity and self.recurring?
      note.time = self.activity.next_recurrence(note.time)
      return note
    end
  end
    
  before_save do |record|
    record.location = "" if record.location_status == "0"
    record.activity.stop = record.activity.start if record.activity and record.activity.start and record.stop.nil?
  end

end
