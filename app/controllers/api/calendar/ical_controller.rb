require 'rubygems'
require 'icalendar'
require 'helpers/calendar_helper.rb'

class Api::Calendar::IcalController < CalendarController
  before_filter :login_required, :except => :index
  before_filter :beta_access, :except => :index
	skip_before_filter :supported_browsers, :only => :index
  include CalendarHelper
  ICAL = [WidgetTodo, CalendarEntry]
  ICAL_RECURRING_UNITS = ["DAILY", "WEEKLY", "MONTHLY", "YEARLY"]	
  ICAL_TODO_PRIO = [9,5,1]

		
	## Generate an output readable by iCal from the stixy calendar.
	#
  def index
    key = !params[:privatekey].nil? ? params[:privatekey] : nil
    user_id = User.get_id_from_private_key(key)
    unless user_id.nil?
      cal = Icalendar::Calendar.new
      cal.custom_property("METHOD","PUBLISH")
      ##  ICALENDAR TODO ##
      # Fetch todo items
      todos ||= CalendarTodo.get_for_global_todolist(user_id)
      todos.each do |t|
          todo = Icalendar::Todo.new
        unless t.priority.nil?
          todo.priority      ICAL_TODO_PRIO[t.priority]
        else
          todo.priority      "0"
        end
          todo.summary       t.calendar_text
          todo.description   t.description
        if t.completed?
          todo.status     "COMPLETED"
        end
        if t.duedate_state
          todo.due t.duedate.strftime("%Y%m%d")
        end
				todo.url calendar_entry_url(:entry_id => t.id)
        cal.add_todo(todo)
      end
      ##  ICALENDAR ENTRIES  ##
      entries = ICAL.collect{ |c| c.get_for_calendar(user_id, Date.civil(1800,01,01), Date.civil(2020,01,01) , {:build_recurring => false}) }
      entries = entries.flatten
      entries.each do |e|
        event = Icalendar::Event.new
        event.klass               "PRIVATE"
        event.dtstart             multi_day_event?(e) ? current_user.adjusted_time(e.start).strftime("%Y%m%d") : current_user.adjusted_time(e.start).strftime("%Y%m%dT%H%M%SZ") #e.start.strftime("%Y%m%d") #e.start.strftime("%Y%m%dT%H%M%SZ")
        event.dtend               multi_day_event?(e) ? current_user.adjusted_time(e.stop+1.day).strftime("%Y%m%d") : current_user.adjusted_time(e.stop).strftime("%Y%m%dT%H%M%SZ") #e.stop.strftime("%Y%m%d") #e.stop.strftime("%Y%m%dT%H%M%SZ")
        
        # Now, to configure Firefox to handle the webcal:// protocol, you'll need to go into Firefox's configuration settings. Do the following:
        # 1. In a blank tab, type about:config. You will be shown a page with a list of Firefox's configuration variables.
        # 2. In the filter field, type network.protocol-handler. This will show a list of protocols handled by Firefox. You may or may not see the webcal protocol in the list. If it's there, it would look something like network.protocol-handler.external.webcal. The protocol is probably not there, though, in which case you'll need to add it.
        # 3. To create the configuration setting, right-click on any item in the list and select New > Boolean. In the preference name, type network.protocol-handler.external.webcal, and set the value to true. This tells Firefox to use an external program to handle the webcal:// protocol.
        # 4. Next, create a new string item by right-clicking anywhere on the list and selecting New > String. In the preference name, type network.protocol-handler.app.webcal, and in the value field, type the path to the program you want to use for that protocol (e.g. c:\Program Files\Microsoft Office\Office\Outlook.exe).
        # 5. Restart Firefox and you should be set.
        
				## LINK ##
				url = case e.class.to_s
					when "WidgetTodo"
						widget_url(:id => e.board_id, :widget_id => e.id)
					when "CalendarEntry"
						calendar_entry_url(:entry_id => e.id)
					else
						calendar_url
				end
				event.url									url #e.type == "CalendarTodo" ? "http://www.stixy.com/calendar/#{t.id}"

        event.summary             e.calendar_text
        event.description         e.description
        if defined? e.location
          event.location          e.location
        end
        if e.activity.recurring?
          event.add_recurrence_rule "FREQ=#{ICAL_RECURRING_UNITS[e.activity.unit]};INTERVAL=#{e.activity.frequency}"
        end
        cal.add_event(event)
      end
 	 		headers['Cache-Control'] = 'private' if headers['Cache-Control'] == 'no-cache'
      headers["Content-Type"] = "text/calendar; charset=utf-8"
			send_data(cal.to_ical, :type => 'text/calendar', :disposition => 'file; filename=stixy_calendar.ics', :filename=>'stixy_calendar.ics')
			#render_without_layout :text => cal.to_ical
      #render :text => cal.to_ical
    else
      render :nothing => true
    end
  end
  
  ## Show adress for private access to subscribe in iCal
	# This should be put somewhere else in the future, popup or something
	def address
	  render :text => subscription_address
	end
	
  ##  Upload an iCal file (.ics)
  #   and import events and todolists to the stixy calendar. 
  #
  def upload
    if request.post?
      cal_file = params[:icalfile].read
      cals = Icalendar.parse(cal_file)
      cals.each do |cal|
        cal.events.each do |event|
          calendarentry = CalendarEntry.new
          calendarentry.subject = event.summary
          calendarentry.location = event.location unless event.location.nil?
          calendarentry.start = Time.parse(event.dtstart.to_s)
          calendarentry.stop = Time.parse(event.dtend.to_s)
          calendarentry.note = event.description unless event.description.nil?
          unless event.recurrence_rules.empty?
            calendarentry.recurring = { :status => 1,
                                        :unit => ICAL_RECURRING_UNITS.index(((event.recurrence_rules.first.match(/FREQ=(\w+);?/)[1]) rescue "DAILY")),
                                        :frequency => ((event.recurrence_rules.first.match(/INTERVAL=(\d+)/)[1]) rescue 1)
                                      }
          end
          calendarentry.add_user = current_user
          calendarentry.save 
        end
        cal.todos.each do |todo|
          calendartodo = CalendarTodo.new
          calendartodo.priority = (ICAL_TODO_PRIO.index(todo.priority) != nil) ? ICAL_TODO_PRIO.index(todo.priority) : 0
          calendartodo.subject = todo.summary
          calendartodo.note = todo.description
          calendartodo.duedate = Time.parse(todo.due.to_s) unless todo.due.nil?
          calendartodo.completed = (todo.status.to_s == "COMPLETED" ? 1 : 0)
          calendartodo.add_user = current_user
          calendartodo.save
        end
      end
    end
		redirect_to :controller => "/calendar", :action => :index, :popup => true
    #render_as_popup do
    #  render :layout => "decorator-popup", :template => "calendar/icalupload" and return
    #end
  end

  
end
