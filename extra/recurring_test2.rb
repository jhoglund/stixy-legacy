require 'time'
require 'date'

class Activity
  UNITS = %w{ DAY WEEK MONTH YEAR }
  YEAR, MONTH, WEEK, DAY = 3, 2, 1, 0
  attr_accessor :start, :stop, :frequency, :unit
  def initialize start, stop, frequency, unit
    @start = start
    @stop = stop
    @frequency = frequency
    @unit = unit
  end
  
  def self.first_recurrence time=Time.now, limit=Time.now, f=1, u=DAY
    l = limit.to_d
    s = time.to_d
    y = (l.year - s.year)
    m = (y * 12) + (l.month - s.month)                 
    d = (l - s).to_i
    n = case u 
        when YEAR  : ((s >> (f==1 || m==0 ? m : ((y + (f - y % f)) * 12))) - s).to_i
        when MONTH : ((s >> (f==1 || m==0 ? m : ((m + (f - m % f))))) - s).to_i
        when WEEK  : ((s +  (f==1 || m==0 ? m : ((d + ((f * 7) - (d % (f * 7))))))) - s).to_i
        else         ((s +  (f==1 || m==0 ? m : ((d + (f - d % f))))) - s).to_i
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
  
  def first_recurrence limit=self.start
    self.class.first_recurrence(self.start, limit, frequency, unit)
  end
  
  def next_recurrence first=self.start
    self.class.next_recurrence(first, self.frequency, self.unit)
  end
  
  def recurrencies range_start=nil, range_stop=nil
    reccurent = first_recurrence(range_start)
    loop do
      break if !range_stop.nil? and reccurent.to_d > range_stop.to_d  
      clone = self.dup
      clone.start = reccurent
      clone.stop = (clone.start + (self.stop - self.start))
      yield clone if block_given?
      break if range_stop.nil?
      reccurent = next_recurrence(reccurent)
    end
  end
  
  private 
  
  
end

class CalendarEntry
  attr_accessor :activity
  def initialize start, stop, frequency, unit
    @activity = Activity.new(start, stop, frequency, unit)
  end
end

# Extensions to the _time_ obect.
class Time
  # Convert to _date_ object
  def to_date; Date.parse(self.to_s) end
  alias :to_d :to_date
  # Fallback method. Returns self
  def to_time; self end
  alias :to_t :to_time
end

# Extensions to the _date_ obect.
class Date
  # Convert to _time_ object
  def to_time; Time.parse(self.to_s) end
  alias :to_t :to_time
  # Fallback method. Returns self
  def to_date; self end
  alias :to_d :to_date
end

ce = CalendarEntry.new(Time.parse("2008-05-20"), Time.parse("2008-05-27 10:03:27"), 2, Activity::MONTH)

#ce.activity.recurrencies(Date.parse("2008-07-20"), Date.parse("2008-08-25")) do |activity|
#  p "Facit: 2008-07-20"
#  p activity.start.to_d.to_s
#end

ce = CalendarEntry.new(Time.parse("2001-05-20 00:00 UTC"), Time.parse("2001-05-27 10:03:27"), 27, Activity::MONTH)

ce.activity.recurrencies(Date.parse("2008-01-20"), Date.parse("2008-09-25")) do |activity|
  p activity.start
end


class Test
  def initialize offset, frequency, equals
    result = yield offset, frequency, equals
    p "#{result} = #{equals}"
    p "--------------"
  end
  
end


def testar
  test = [[17,3,18], [8,3,9], [6,5,10], [5,1,5], [0,1,0], [0,3,0], [0,2,0], [7,7,7]]
  def calculate o,f,formula
    (o==0 || f==1) ? o : formula
  end
  test.each do |a|
    Test.new(*a) do |m,f,e|
      p a.inspect
      #p "(#{m} + (#{f} - (#{m} % #{f}) = #{m % f}))"
      ((f==1 || m==0 || f==m ? m : (m + (f - m % f))))
    end  
  end
end

#date = Date.parse("2001-05-20")
#stop = Date.parse("2008-08-20")
#loop do
#  break if date > stop
#  p date.to_s
#  date = date >> 7
#end

testar


