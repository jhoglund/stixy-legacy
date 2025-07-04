module Widgets::TodoHelper
  
  #def calendar(options = {}, &block)
  #  calendar = Stixy::Calendar.new(options[:year], options[:month])    
  #  table = calendar.to_html_table { |date, day, cell| cell.content = day.day }
  #  table.setHeaders(*calendar.offsetDays(Date::ABBR_DAYNAMES.dup))
  #  table.addAttribute(:class, "todo-calendar")
  #  return table.to_s
  #end
  #
  #def update_calendar_date(year_nav=0, month_nav=0, reset_year=nil, reset_month=nil)
  #  date = current_user.adjusted_time
  #  session[:calendar] ||= { :year => date.year, :month => date.month}
  #  session[:calendar][:year] = reset_year.to_i if reset_year
  #  session[:calendar][:month] = reset_month.to_i if reset_month
  #  return if reset_year or reset_month
  #  return (session[:calendar][:year], session[:calendar][:month] = date.year, date.month) if year_nav.nil? and month_nav.nil?
  #  year, month = session[:calendar][:year], session[:calendar][:month]
  #  month_nav = month_nav.to_i
  #  year_nav = year_nav.to_i
  #  if month_nav
  #    month_nav = session[:calendar][:month] + month_nav
  #    if month_nav < 1
  #      year_nav = year_nav - 1
  #      month_nav = 12
  #    elsif month_nav > 12
  #      year_nav = year_nav + 1
  #      month_nav = 1
  #    end
  #    session[:calendar][:year], session[:calendar][:month] = (year + year_nav), month_nav
  #  end
  #end
  
end
