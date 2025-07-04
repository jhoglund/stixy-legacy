require 'benchmark'
module DateHelper
  NUMERIC_DATE_FORMATS_NAMES  = [ "31/12/2008", "31/12/08", "12/31/2008", "12/31/2008", "2008/12/31", "08/12/31" ]
  NUMERIC_DATE_FORMATS_VALUES = [ "%d/%m/%Y", "%d/%m/%y", "%m/%d/%Y", "%m/%d/%y", "%Y/%m/%d", "%y/%m/%d" ]
  NUMERIC_DATE_SEPARATORS = %w{ . / - }
  STRING_DATE_FORMATS_NAMES  = [ "December 31, 2007", "31 December 2007" ]
  STRING_DATE_FORMATS_VALUES = [ "%B %d, %Y", "%d %B %Y" ]
  TIME_FORMATS_NAMES  = [ "13:00", "01:00 PM" ]
  TIME_FORMATS_VALUES = [ "%H:%M", "%I:%M %p" ]
  
  class DateFormat
    def initialize values=nil
      from_s(values)
    end
    
    def from_s values=nil
      values ||= "n2s1d0t1w0"
      @numeric_date, @date_separator, @string_date, @time, @week = values[1,1].to_i, values[3,1].to_i, values[5,1].to_i, values[7,1].to_i, values[9,1].to_i
      @numeric_date_formats_names  = NUMERIC_DATE_FORMATS_NAMES[@numeric_date]
      @numeric_date_formats_values = NUMERIC_DATE_FORMATS_VALUES[@numeric_date]
      @numeric_date_separators     = NUMERIC_DATE_SEPARATORS[@date_separator]
      @string_date_formats_names   = STRING_DATE_FORMATS_NAMES[@string_date]
      @string_date_formats_values  = STRING_DATE_FORMATS_VALUES[@string_date]
      @time_formats_names          = TIME_FORMATS_NAMES[@time]
      @time_formats_values         = TIME_FORMATS_VALUES[@time]
    end
    
    def get_numeric_date
      { :name => @numeric_date_formats_names, :value => @numeric_date_formats_values }
    end
    
    def get_string_date
      { :name => @string_date_formats_names, :value => @string_date_formats_values }
    end
    
    def get_time
      { :name => @time_formats_names, :value => @time_formats_values }
    end
    
    def to_numeric_date time = Time.now
      time.strftime(@numeric_date_formats_values.gsub("/",@numeric_date_separators))
    end
    
    def to_string_date time = Time.now
      time.strftime(@string_date_formats_values)
    end
    
    def to_time time = Time.now
      time.strftime(@time_formats_values)
    end
    
    def twelve_hour_clock?
      @time == 1
    end
    
    def week?
      @week == 1
    end
    
    def set args={}
      args.each do |key,value| 
        self.instance_variable_set(("@#{key.to_s}").to_sym, value)
      end
    end
    
    def to_s
      "n#{@numeric_date}s#{@date_separator}d#{@string_date}t#{@time}"
    end

  end

end