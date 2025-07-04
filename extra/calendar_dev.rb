require 'date'

module Stixy
  
  module Html
  
    class Element
      attr_accessor :content
    
      def initialize name, content=""
        @attributes = {}
        @children = []
        @name = name.to_s.downcase
        @content = content
      end
    
      def addChildNode child
        @children << child
        return child
      end
    
      def addChild name="div", value=""
        addChildNode(Element.new(name.to_s, value))
      end
    
      def setAttribute name, value
        @attributes[name.to_s] ||= Attribute.new(name, value)
      end
    
      def addAttribute name, value
        if attribute = @attributes[name]
          attribute.addValue(value)
        else
          @attributes[name.to_s] ||= Attribute.new(name, value)
        end
      end
    
      def getAttribute name
        @attributes[name.to_s]
      end
    
      def removeAttribute name
        @attributes.delete(name.to_s)
      end
    
      def to_s index=0
        "<#{@name.downcase}#{attributes_to_s}>\n#{tabs(index)}#{children_to_s(index)}#{@content}\n</#{@name.downcase}>\n"
      end
      
      protected
      
      def tabs size=0
        str = ""
        (0...size).each do 
          str += "\t"
        end
        return str
      end
      
      private
    
      def attributes_to_s
        str = ""
        @attributes.each do |name, attribute|
          str << " #{attribute.to_s}"
        end
        return str
      end
    
      def children_to_s index
        str = ""
        @children.each do |child|
          str += child.to_s(index+1)
        end
      end
    
    end
  
    class Attribute
      @@delimeters = {:style => "; "}
      def initialize name, value
        @values = [] << value
        @name = name.to_s
      end
      
      def removeValue value
        @values.delete(value)
      end
    
      def addValue value
        @values.push(value)
      end
    
      def setValues value
        @values = [value]
      end
    
      def getValues
        @values
      end
      
      def value
        @values.join((@@delimeters.values_at(@name.to_sym).first||" ").to_s)
      end
    
      def to_s
        @name + '="' + value + '"'
      end
    end
  
    class Table < Element
      attr_accessor :column_size
      def initialize *headers
        setHeaders(headers)
        @cells = []
        @column_size = 0
        super "table"
      end
      
      def setHeaders *headers
        @headers = headers.collect {|title| Th.new(title) }
        return @headers
      end
    
      def setColumnSize size=1
        @column_size = size
      end
    
      def << content=nil
        return addCell(content)
      end
    
      def addCell content="&nbsp;"
        cell = Td.new(content)
        @cells << cell
        return cell
      end
    
      def cell
        addCell(yield)
      end
    
      alias :super_to_s :to_s
      def to_s
        to_table.super_to_s
      end
    
      def to_table
        calculateColumnSize()
        unless @headers.empty?
          @thead = Thead.new
          @row = Tr.new
          @headers.each do |header|
            @row.addChildNode(header)
          end
          @thead.addChildNode(@row)
          self.addChildNode(@thead)
        end
        @tbody = Tbody.new
        @cells.each_with_index do |cell, index|
          @row = Tr.new if new_row?(index)
          @row.addChildNode(cell)
          @tbody.addChildNode(@row) if new_row?(index)
        end
        self.addChildNode(@tbody)
        return self
      end
    
      private
      
      def calculateColumnSize
        return @column_size if @column_size > 0
        @headers.each do |h|
          size = (colspan = h.getAttribute(:colspan)) ? colspan.value.to_i : 1
          @column_size += size
        end
        setColumnSize if @column_size==0
      end
        
      def new_row? index
        index % @column_size == 0
      end
    end
  
    class Tr < Element
      def initialize *arg
        super "tr", arg
      end
    end
  
    class Th < Element
      def initialize *arg
        super "th", arg
      end
    end
  
    class Td < Element
      def initialize *arg
        super "td", arg
      end
    end
    
    class Tbody < Element
      def initialize *arg
        super "tbody", arg
      end
    end
    
    class Thead < Element
      def initialize *arg
        super "thead", arg
      end
    end
    
  end

  class Calendar
    attr_accessor :dates, :day_names
    def initialize year=Date.new.year, month=Date.new.month, start_week=1
      @month = month 
      @year = year 
      @start = Date.civil(@year, @month, 1)
      @stop = Date.civil(@year, @month, -1)
      @start -= @start.wday
      @stop += (6-@stop.wday)
      @day_names = Date::DAYNAMES.dup
      setStartDay(start_week)
      @dates = []
      @start.upto(@stop) do |day|
        @dates << CalendarDate.new(day,@month,@year,@start_week,@last_weekday)
      end
    end
  
    def setStartDay start_week=0
      @first_weekday = start_week
      @last_weekday = start_week-1>=0 ? start_week-1:6
      @first_weekday.times do
        @day_names.push(@day_names.shift)
      end
    end
    
    def to_html_table options={}, &block
      table = Html::Table.new(*day_names)
      dates.each do |date|
        cell = table.addCell
        cell.addAttribute(:class, "otherDay") if date.other_month?
        cell.addAttribute(:class, "todayDay") if date.today?
        cell.addAttribute(:class, "firstDayOfWeek") if date.first_weekday?
        cell.addAttribute(:class, "lastDayOfWeek") if date.last_weekday?
        cell.addAttribute(:class, "weekendDay") if date.weekend?
        cell.setAttribute(:id, "#{date.day.year}-#{Date::MONTHNAMES[date.day.month]}-#{Date::DAYNAMES[date.day.wday]}-#{date.day.day}")
        cell.content = block_given? ? block.call(date.day, cell) : date.day
      end
      table.setAttribute(:class, "calendar")
      table.setAttribute(:border, "0")
      table.setAttribute(:cellspacing, "0")
      table.setAttribute(:cellpadding, "0")
      return table
    end
    
  
    class CalendarDate
      attr :day
    
      def initialize day,month,year,start_week,last_weekday
        @day = day
        @month = month 
        @year = year 
        @first_weekday = start_week
        @last_weekday = last_weekday
      end
    
      def first_weekday?
         @day.wday == @first_weekday
      end
  
      def last_weekday?
        @day.wday == @last_weekday
      end
  
      def other_month?
        @day.month != @month
      end
  
      def weekend?
        [0, 6].include?(@day.wday) 
      end
  
      def today?
        @day == Date.today
      end
    end
  
  end
end

def link_to_function a,b
  "sss"
end
options = {:year => 2008, :month => 1}
calendar = Stixy::Calendar.new(Date.civil(options[:year], options[:month]))    
table = calendar.to_html_table do |day, cell|
  cell.addAttribute(:class, "day")
  day.wday 
end
table.setAttribute("id", "todo_calendar")
headers = table.setHeaders(%Q{
  <div>
    <span class="prev-month" id="todo_calendar_nav_previuos">#{link_to_function "&nbsp;", "Stixy.nothing()"}</span>
    <span class="todo-calendar-month-title"><span id="todo_progress_indicator" style="display:none"></span>#{Date::MONTHNAMES[options[:month]]} #{options[:year]}</span>
    <span class="next-month" id="todo_calendar_nav_next">#{link_to_function "&nbsp;", "Stixy.nothing()"}</span>
  </div>
})
headers.first.setAttribute(:colspan, "7")
p table.to_s
