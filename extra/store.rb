require 'date'

class Class # :nodoc:
  def cattr_reader(*syms)
    syms.flatten.each do |sym|
      next if sym.is_a?(Hash)
      class_eval(<<-EOS, __FILE__, __LINE__)
        unless defined? @@#{sym}
          @@#{sym} = nil
        end

        def self.#{sym}
          @@#{sym}
        end

        def #{sym}
          @@#{sym}
        end
      EOS
    end
  end

  def cattr_writer(*syms)
    options = syms.last.is_a?(Hash) ? syms.pop : {}
    syms.flatten.each do |sym|
      class_eval(<<-EOS, __FILE__, __LINE__)
        unless defined? @@#{sym}
          @@#{sym} = nil
        end

        def self.#{sym}=(obj)
          @@#{sym} = obj
        end

        #{"
        def #{sym}=(obj)
          @@#{sym} = obj
        end
        " unless options[:instance_writer] == false }
      EOS
    end
  end

  def cattr_accessor(*syms)
    cattr_reader(*syms)
    cattr_writer(*syms)
  end
end


class ActivityTmp
  attr_accessor :subject, :location, :note, :calendar_text, :start, :stop
  cattr_accessor :queued_activities
  @@queued_activities = []
  def initialize title, start, stop=nil
    @subject = subject
    @start = Date.parse("2008-01-#{start}")
    @stop = stop.nil? ? @start : Date.parse("2008-01-#{stop}")
  end  
end
def store_or_remove_multiday event, i, day
  unless event.nil?
    event.queued_activities[i] = event unless event.start == event.stop
    event.queued_activities[i] = nil if day == event.stop.day
  end
end
def include_multiday arr
  ActivityTmp.queued_activities.each_with_index do |t,i|
    arr.insert(i, t) unless t.nil?
  end
  return arr
end

activities = []
activities << ActivityTmp.new("a",3)
activities << ActivityTmp.new("b",1,2)
activities << ActivityTmp.new("c",1)
activities << ActivityTmp.new("d",2)
activities << ActivityTmp.new("e",2)
activities << ActivityTmp.new("f",2,4)
activities << ActivityTmp.new("g",2,3)
activities << ActivityTmp.new("h",3)
activities << ActivityTmp.new("i",3,5)
activities << ActivityTmp.new("j",5,6)
activities << ActivityTmp.new("k",7)
activities << ActivityTmp.new("l",3)
activities << ActivityTmp.new("m",2,8)
activities << ActivityTmp.new("n",8)
activities = activities.sort_by{|activity| activity.start }

Date.civil(2008,1).upto(Date.civil(2008,1,-1)) do |date|
  today_activities = activities.select{|activity| activity.start.day==date.day}
  today_activities = today_activities.sort_by{|activity| activity.stop }.reverse
  include_multiday(today_activities).each_with_index do |event, index|
    store_or_remove_multiday(event, index, date.day)
  end
  p date.day
end
