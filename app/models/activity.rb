class Activity < ActiveRecord::Base
	before_create :before_create
#	after_create :after_create
	belongs_to	:activatable,	 :polymorphic => true
	has_many		:logs,				 :as => :loggable
	has_one			:notification, :as => :noteable, 		:dependent => :destroy


  # mapping arrays for enums
  RECURRING_STATUS = %w{RECURRING_FALSE RECURRING_TRUE}
  # status values enum
  RECURRING_FALSE, RECURRING_TRUE = 0, 1

	UNITS = %w{ DAY WEEK MONTH YEAR }
	DAY, WEEK, MONTH, YEAR = 0, 1, 2, 3


	#validates_date_time :start,		:message => "Error: Startdate"
	#validates_date_time :stop,		:message => "Error: Stopdate", :if => Proc.new{|a| !a.stop.nil? }



	def self.get_for_calendar(user_id, start = Date.today, stop = start+31)
		Activity.find(	:all,
										:conditions => ["members.user_id = ? AND
																		((start >= ? AND start < ?) OR (stop >= ? AND stop < ?)) ",
																		user_id, start, stop, start, stop],
										:include => [:members])
	end
	
  def self.first_recurrence time=Time.now, limit=Time.now, f=1, u=DAY
    s = time.to_d
    l = limit.to_d
    y = (l.year - s.year)
    m = (y * 12) + (l.month - s.month) + (s.day < l.day ? 1 : 0)                
    d = (l - s).to_i
    n = case u 
        when YEAR  : ((s >> (m - (m % -(f * 12)))) - s).to_i
        when MONTH : ((s >> (m - (m % -f))) - s).to_i
        when WEEK  : ((s +  (d - (d % -(f * 7)))) - s).to_i
        else         ((s +  (d - (d % -f))) - s).to_i
        end
    time + ([n,0].max*60*60*24)
  end
  
  def self.next_recurrence time=Time.now, f=1, u=DAY
    s = time.to_d
    n = case u 
        when YEAR  : (s >> (f * 12)) - s
        when MONTH : (s >> (f)) - s
        when WEEK  : (f * 7)
        else         (f)
        end
    time + (n*60*60*24)
  end
  
  def first_recurrence limit=self.start, time=self.start
    self.class.first_recurrence(time, limit, frequency, unit)
  end
  
  def next_recurrence first=self.start
    next_recurring = self.class.next_recurrence(first, self.frequency, self.unit)
    if self.start.day != next_recurring.day and self.unit == MONTH
      last_day = [self.start.day, Date.civil(next_recurring.year, next_recurring.month, -1).day].min 
      days_difference = last_day - next_recurring.day
      next_recurring = next_recurring + (days_difference*60*60*24)
    end
    next_recurring
  end
  
  def duration
    self.stop - self.start
  end
  
  def recurrencies range_start=nil, range_stop=nil
    reccurent = first_recurrence(range_start, self.stop)
    if (reccurent-duration).to_d < range_start.to_d and not range_stop.nil?
      clone = self.clone
      clone.start = reccurent - duration
      clone.stop = reccurent
      yield clone if block_given?
    end
    reccurent = first_recurrence(range_start)
    loop do
      break if !range_stop.nil? and reccurent.to_d > range_stop.to_d  
      clone = self.clone
      clone.start = reccurent
      clone.stop = reccurent + duration
      yield clone if block_given?
      break if range_stop.nil?
      reccurent = next_recurrence(reccurent)
    end
  end
	
	def recurring?
	  recurring_status == Status::ACTIVE
  end

	def users= *args
		@users = args
	end

	private
	
	def before_create
		if self.stop.nil?
			self.stop = self.start
		end
	end  
	
	before_save do |record|
	  unless record.start or (Time.parse(record.start) rescue nil)
	    record.errors.add("Error: Startdate")
	    next false
    end
	  if record.stop.nil? or record.stop < record.start
			record.stop = record.start
		end
	end  
	
  def after_create
			@users.each do |u|
				member = Member.create(:user_id => u.object_id, :membershipable_id => self.id, :membershipable_type => self.class)
			end
  end

end
