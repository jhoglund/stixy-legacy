require 'date'

UNITS = %w{ YEAR MONTH WEEK DAY }
YEAR, MONTH, WEEK, DAY = 0, 1, 2, 3

class Activity
  attr_accessor :start, :stop
  def initialize start, stop
    @start = start
    @stop = stop
  end
end

class CalenderEntry
  @@entry_id = 0
  attr_accessor :frequency, :unit, :activity, :id
  def initialize start, stop, frequency, unit=DAY
    @activity = Activity.new(start, stop || start)
    @frequency = frequency
    @unit = unit
    @@entry_id += 1
    @id = @@entry_id
  end
end

range_start = (Date.civil(2007,1,1) - Date.civil(2007,1,1).wday)
range_stop  = (Date.civil(2008,12,-1) + (6-Date.civil(2008,12,-1).wday))

calenderEntries  = [
  CalenderEntry.new(Time.local(2007,12,21), Time.local(2002,12,22), 37, DAY), 
  CalenderEntry.new(Time.local(2007,12,21), Time.local(2002,12,22), 27, WEEK), 
  CalenderEntry.new(Time.local(2002,7,31), Time.local(2002,11,30), 5, MONTH),
  CalenderEntry.new(Time.local(2002,7,30), Time.local(2002,11,30), 1, YEAR)
]

activities = []

p "#{range_start.to_s} => #{range_stop.to_s}"
calenderEntries.each do |ce|
  entry_start = Date.civil(ce.activity.start.year,ce.activity.start.month,ce.activity.start.day)
  start = case ce.unit 
          when YEAR
            year = Date.civil((entry_start.year + (range_start.year - entry_start.year)),entry_start.month,entry_start.day)
            year = Date.civil((year.year + ce.frequency),entry_start.month,entry_start.day) if year < range_start
            year
          when MONTH
            offset  = (((range_start.year - entry_start.year) * 12)-(entry_start.month-range_start.month))
            offset  = offset + ((ce.frequency-1) - (offset % ce.frequency))
            month   = (entry_start >> offset)
            month   = month >> ce.frequency if month < range_start
            month
          else range_start + (ce.frequency - ((range_start - entry_start) % ce.frequency))
          end
  while start <= range_stop
    clone = ce.dup
    clone.activity = ce.activity.clone
    clone.activity.start = Time.local(start.year,start.month,start.day,ce.activity.start.hour,ce.activity.start.min,ce.activity.start.sec)
    clone.activity.stop = (clone.activity.start + (ce.activity.stop - ce.activity.start))
    clone.id = ce.id      
    activities << clone
    start = case ce.unit 
            when YEAR   : Date.civil((start.year+ce.frequency),start.month,start.day)
            when MONTH  : 
              next_month = (start >> ce.frequency)
              last_day = Date.civil(next_month.year,next_month.month,-1).day
              Date.civil(next_month.year,next_month.month,[entry_start.day,last_day].min)
            when WEEK   : start + (ce.frequency * 7)
            when DAY    : start + ce.frequency
            end
    p "INSIDE: #{clone.activity.start} => #{UNITS[clone.unit]}"
  end
end

p activities.sort_by {|e| e.activity.start }.collect {|e| "#{e.activity.start} => #{UNITS[e.unit]}" }.join(",")

#p "2002-10-12 => 2007-12-30"
#p "2008-2002 = 5"
#p "5*12 = 60"
#p "11 - 12 = -1"
#p "60-(-2) = 62"
#p "2007-12-12"