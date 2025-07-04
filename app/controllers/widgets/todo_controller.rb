class Widgets::TodoController < Widgets::DefaultController
  include Widgets::TodoHelper
  skip_before_filter :session_is_lost, :except => :ajax_user_list
  
  def self.update_widget todo, params, user
    params[:time] = (params[:time]) ? user.reset_time(Time.parse(params[:time])) : todo.time
    # We need to iterate through any possible reminders 
    # and reset the notifications to reflect the new time. 
    if not todo.id.nil? and not todo.reminders.empty?
      reminder_time_offset = params[:time] - todo.reminders.first.time
      todo.reminders.each{|r| r.update_attribute(:time, params[:time]-reminder_time_offset)}
    end
    if reminder = params[:reminder]
      todo.reminders.destroy_all
      if reminder[:remind_at].to_f != 0.0
        reminder[:remind_users].each do |user_id, status|
          if status.to_i==1
            todo.reminders.create(:user_id => user_id, :time => params[:time]-(reminder[:remind_at].to_f*(60*60)), :created_by => user, :updated_by => user, :status => Status::PENDING)
          end
        end
      end
    end
    params.delete(:reminder)


    todo.attributes = params
    return todo
  end
  
  def ajax_user_list
    @board = Board.find(params[:id]) rescue Board.new
    render :partial => "/widgets/todo/user_list"
  end
  
  def ajax_calendar
    render :partial => "/widgets/todo/todo_calendar"
  end
end
