class CalendarController < Stixyboard
  before_filter :login_required
	before_filter :beta_access, :except => [:beta_signup]
	before_filter :prepare, :except => [:beta_signup]
	
  def index
    if request.xhr?
      params[:calendar_date] = params[:body][:date]
      render_result(:calendar => true)
    else
      render_as_popup
    end
	end
	
	def day
	  render_as_popup do
	    render :layout => "decorator-popup", :template => "calendar/day" and return
    end
  end

	def year
	  render_as_popup do
	    render :layout => "decorator-popup", :template => "calendar/year" and return
    end
  end

	def show
    render_result(:calendar => false, :edit => true)
  end
  
  def remove 
    @entry.remove
	  save_entry do
	    @entry = get_entry_class.new(:start => current_user.adjusted_time(Time.new))
	    next false
    end
  end

	def edit 
	  set_entry
    save_entry
  end
  
  def create 
	  set_entry
    save_entry do |calendar|
      if calendar.includes?(to_date(current_user.adjusted_time(@entry.activity.start)))
        next false
      else
        next @entry.activity.start
      end
    end
  end
  

	def synchronize
	  render_as_popup do
	    render :layout => "decorator-popup", :template => "calendar/synchronize" and return
    end

	end
	
  def clear_completed 
	  CalendarTodo.clear_completed(current_user.id);
    render_result(:calendar => true, :edit => true)
    #render :nothing => true
  end
	
	def beta_signup
		max_beta_users = 100000
	  @beta_tester_size = Role.find(Role::CALENDAR_BETA_TESTER).users.count
		@beta_full = (@beta_tester_size >= max_beta_users) ? true : false
		@pending = (current_user.in_role? Role::CALENDAR_PENDING) ? true : false
		if params[:signup] == "true" && ((current_user.in_role? Role::CALENDAR_BETA_TESTER) == false) && (@pending == false)
			if @beta_full == false
				current_user.roles << Role.find(Role::CALENDAR_BETA_TESTER)
				signup_confirm and return
			else
				current_user.roles << Role.find(Role::CALENDAR_PENDING)
				notify_confirm and return
			end
		elsif current_user.in_role? Role::CALENDAR_BETA_TESTER
			redirect_to :controller => :calendar, :action => :index and return
		else
			calendar_overview and return
		end
	end

	def signup_confirm
		render_as_popup do
			render :layout => "decorator-public", :template => "/calendar/signup_confirmed" and return
		end and return
  end
  
  def notify_confirm
		render_as_popup do
			render :layout => "decorator-public", :template => "/calendar/interest" and return
		end and return
  end
	
	def calendar_overview
	  render_as_popup do
			render :layout => "decorator-public", :template => "/calendar/beta_signup" and return
		end and return
  end
  
  def calendar_test
	  case params[:view]
    when "confirm"
      signup_confirm
    when "notify_pending"
      @pending = true
      calendar_overview
    when "notify"
      @beta_full = true
      calendar_overview
    when "notify_confirm"
      notify_confirm
    else
      calendar_overview
    end
  end
	

  private
  
  def set_entry 
	  @entry.users = get_users
    @entry.attributes = params[:body][@entry.class.to_s.underscore]
    @entry.start = current_user.reset_time(@entry.start) unless @entry.start.nil?
    @entry.stop = current_user.reset_time(@entry.stop) unless @entry.stop.nil?
  end
  
  def prepare
    @time = Time.parse(params[:id]) rescue current_user.adjusted_time(Time.new)
    get_entry
    @entry.current_user = current_user if defined? @entry.current_user
    @selected_day = Time.parse(params[:body].delete(:selected_day)) rescue current_user.adjusted_time(Time.now)
    @selected_calendar = Time.parse(params[:body].delete(:selected_calendar)) rescue nil
  end
  
  def get_entry_class
    params[:body][:entry_type][:value].classify.constantize rescue CalendarEntry
  end
  
  def get_entry
    entry_class = get_entry_class
    @calendar_todo = CalendarTodo.new(:duedate => @time, :duedate_state => 0)
    @calendar_entry = CalendarEntry.new(:start => @time, :stop => @time)
    @selected_entry = AbstractCalendar.find_for_user(params[:entry_id], current_user.id) rescue nil
    @entry = entry_class.find_for_user(params[:body][entry_class.to_s.underscore][:id].gsub(/[^\d*]/,""), current_user.id) rescue entry_class.new(:start => @time, :stop => @time)
    @entry = @selected_entry unless @selected_entry.nil?
    instance_variable_set("@#{@entry.class.to_s.underscore}", @entry)
    @calendar_entry = @entry
  end
	  
  def save_entry
    if @entry.save!
      @calendar = Stixy::Calendar.new(@selected_calendar || calendar_date)
      new_date = yield @calendar if block_given?
	    @calendar = Stixy::Calendar.new(new_date) if new_date
      render_result(:calendar => true, :edit => true)
    else
      render :partial => "panel"
    end
  end

  def render_result opt={}
    render_ajax_result do |result|
      if opt[:calendar] == true
        result.replace :calendar, render_to_string(:partial => "calendar", :object => @entry) 
        result.replace :activity_list, render_to_string(:partial => "activity_list", :object => @entry)
        result.replace :todo_list, render_to_string(:partial => "todo_list", :object => @entry)
        result.script "Stixy.calendar.initCalendar(#{@entry.nil? ? 0 : @entry.id});"
      end   	 
      if opt[:edit] == true
        result.replace :edit_entry_panel, render_to_string(:partial => get_partial(@entry, :panel), :object => @entry)
        if @entry.class == CalendarEntry
          result.script "Stixy.calendar.initCalendarEntryPanel(Stixy.calendar.edit_panel, Stixy.calendar.edit_panels.calendar_entry);"
        elsif @entry.class == CalendarTodo
          result.script "Stixy.calendar.initTodoPanel(Stixy.calendar.edit_panel, Stixy.calendar.edit_panels.calendar_todo);"
        end
      end
    end
  end
  
  def get_users
    users_ids = params[:body][:users] ||= []
	  users_ids.delete(current_user.id)
	  users = [current_user]
	  users << User.find(*users_ids) unless users_ids.empty?
	  return users
  end
  
  def beta_access
    if !current_user.in_role? Role::CALENDAR_BETA_TESTER
      options = { :controller => :calendar, :action => :beta_signup }
      options.merge!(:popup => true) if params[:popup]
		  redirect_to options
		  return false
	  end
	end
  
end
