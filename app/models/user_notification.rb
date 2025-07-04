class UserNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :widget_instance
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by_id"
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by_id"
  
  # This hould probably be done in a different way. Right now one mail per reminder is sent.
  # It would probably be more efficant to send on reminder, with all users as recipents.
  # This has to be investigated at some point
  def self.pending(time=Time.now)
    reminders = self.find_reminders(time)
    # If the user_id is 0, then the reminder should be send to all users
    # There is more elegant ways of doing this (through a joint table), but it's sufficent for now,
    # and I like to keep the db structure non cluttered
    reminders.select{|r| r.user_id == 0 }.each do |reminder|
      # Remove siblings to the "All" reminder. There might be reminders for users of the widget
      # even though there is one reminder set to "All". This so we can pre-check select boxes in the
      # user list with last check state, even if the widget is set to remind all
      reminders.delete_if{|item| item.widget_instance_id == reminder.widget_instance_id }
      # Temp array that will hold a clone of the reminder instance for each user of the board
      temp_a = Array.new
      if widget_instance = reminder.widget_instance
        widget_instance.board.users.each do |user|
          new_reminder = reminder.clone
          new_reminder.user = user
          new_reminder.widget_instance = reminder.widget_instance
          temp_a.push(new_reminder)
       end
      end
      # Sort the array of "all" users after ID (defaults to firstname), to make it easier to test.
      reminders.concat(temp_a.sort_by{|r| r.user.id })
    end
    
    return reminders
  end
  
  def self.deactivate(time=Time.now)
    reminders = self.find_reminders(time)
    reminders.each do |r|
      r.update_attribute(:status, Status::FINISHED)
    end
    return reminders.size
  end
  
  private
  
  def self.find_reminders(time)
    # Don't include disabled users or boards. This should be done differently. 
    # The user notifications should be disabled if a widget or user is disabled.
    # However, widgets don't have a status yet, so a widget can't be diabled.
    # This has to be fixed first.
    find(:all, :include => :widget_instance, :conditions => ["user_notifications.status = ? and user_notifications.time <= ? and widget_instances.board_id in (select id from boards where status=?) and (user_notifications.user_id in (select id from users where status=?) or user_notifications.user_id=0)", Status::PENDING, time.strftime("%Y-%m-%d %H:%M:%S"), Status::ACTIVE, Status::ACTIVE], :order => "widget_instance_id, user_id")
  end
end
