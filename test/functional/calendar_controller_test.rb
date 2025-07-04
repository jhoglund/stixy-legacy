require File.dirname(__FILE__) + '/../test_helper'
require 'calendar_controller'

# Re-raise errors caught by the controller.
class CalendarController; def rescue_action(e) raise e end; end

class CalendarControllerTest < Test::Unit::TestCase
  fixtures :users, :boards, :boardusers, :abstract_calendars, :members, :notifications, :roles, :roles_users
  
  def setup
    @controller = CalendarController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    jonas = signin_as(:jonas)
    BetaTester.create(:user => jonas)
  end


  def test_new_calendarentry
    start_size = CalendarEntry.find(:all, :select => :id).size
    post :create, {"body"=>{"entry_type"=>{"value"=>"calendar_entry"}, "selected_day"=>"2008-02-09", "calendar_entry"=>{"notification_state"=>"1", "notification_value"=>"1", "stop"=>{"month"=>"02", "minute"=>"00", "hour"=>"03", "day"=>"09", "year"=>"2008", "suffix"=>"PM"}, "notification_unit"=>"0", "subject"=>"blaha", "start"=>{"month"=>"02", "minute"=>"00", "hour"=>"02", "day"=>"09", "year"=>"2008", "suffix"=>"PM"}, "recurring"=>{"status"=>"1", "unit"=>"0", "frequency"=>"1"}, "note"=>"Test Note", "location"=>"Khamn"}}}
    after_size = CalendarEntry.find(:all, :select => :id).size
    assert_equal (start_size+1), after_size
  end
  
  def test_edit_calendarentry
    post :create, {"body"=>{"entry_type"=>{"value"=>"calendar_entry"}, "selected_day"=>"2008-02-09", "calendar_entry"=>{"notification_state"=>"1", "notification_value"=>"1", "stop"=>{"month"=>"02", "minute"=>"00", "hour"=>"03", "day"=>"09", "year"=>"2008", "suffix"=>"PM"}, "notification_unit"=>"0", "subject"=>"blaha", "start"=>{"month"=>"02", "minute"=>"00", "hour"=>"02", "day"=>"09", "year"=>"2008", "suffix"=>"PM"}, "recurring"=>{"status"=>"1", "unit"=>"0", "frequency"=>"1"}, "note"=>"Test Note", "location"=>"Khamn"}}}
    entry = CalendarEntry.find(:first)
    id = entry.id
    new_title = "Edited " + entry.subject
    post :edit, {"body"=>{"entry_type"=>{"value"=>"calendar_entry"}, "selected_day"=>"2008-03-06", "calendar_entry"=>{"notification_state"=>"0", "notification_value"=>"1", "stop"=>{"month"=>"03", "minute"=>"00", "hour"=>"04", "day"=>"06", "year"=>"2008", "suffix"=>"PM"}, "notification_unit"=>"1", "id"=>"_#{id}", "subject"=>new_title, "start"=>{"month"=>"03", "minute"=>"00", "hour"=>"03", "day"=>"06", "year"=>"2008", "suffix"=>"PM"}, "recurring"=>{"status"=>"0", "unit"=>"0", "frequency"=>"1"}, "note"=>"Teest", "location"=>"Ronneby"}}}
    entry2 = CalendarEntry.find(id)
    assert_equal new_title, entry2.subject
    post :remove, {"body"=>{"entry_type"=>{"value"=>"calendar_entry"}, "selected_day"=>"2008-03-06", "calendar_entry"=>{"notification_state"=>"0", "notification_value"=>"1", "stop"=>{"month"=>"03", "minute"=>"00", "hour"=>"04", "day"=>"06", "year"=>"2008", "suffix"=>"PM"}, "notification_unit"=>"1", "id"=>"_#{id}", "subject"=>"Edited test", "start"=>{"month"=>"03", "minute"=>"00", "hour"=>"03", "day"=>"06", "year"=>"2008", "suffix"=>"PM"}, "recurring"=>{"status"=>"0", "unit"=>"0", "frequency"=>"1"}, "note"=>"Teest", "location"=>"Ronneby"}}}
    entry3 = CalendarEntry.find(id)
    assert_equal Status::DISABLED, entry3.status
    assert_equal Status::DISABLED, entry3.activity.status
  end
  
  def test_calendarentry_recurring_notification
    CalendarEntry.delete_all
    today = Time.now
    post :create, {"body"=>{"entry_type"=>{"value"=>"calendar_entry"}, "selected_day"=>"2008-02-09", "calendar_entry"=>{"notification_state"=>"1", "notification_value"=>"3", "notification_unit" => Notification::DAY, "stop"=>{"month"=>"02", "minute"=>"00", "hour"=>"03", "day"=>"09", "year"=>"2008", "suffix"=>"PM"}, "notification_unit"=>"0", "subject"=>"blaha", "start"=>{"month"=>"02", "minute"=>"00", "hour"=>"02", "day"=>"09", "year"=>"2008", "suffix"=>"PM"}, "recurring"=>{"status"=>"1", "unit"=>"0", "frequency"=>"1"}, "note"=>"Recurring", "location"=>"Khamn"}}}
    entry = CalendarEntry.find(:first)
    assert_equal entry.notification.remind_time.to_d, entry.activity.first_recurrence.to_d
  end
  
  def test_new_calendartodo
    start_size = CalendarTodo.find(:all, :select => :id).size
    post :create, {"body"=>{"entry_type"=>{"value"=>"calendar_todo"}, "selected_day"=>"2008-03-05", "calendar_todo"=>{"completed"=>"0", "notification_state"=>"0", "notification_value"=>"1", "notification_unit"=>"1", "priority"=>"0", "subject"=>"Todo Test", "duedate"=>{"month"=>"03", "minute"=>"00", "hour"=>"12", "day"=>"05", "year"=>"2008", "suffix"=>"PM"}, "note"=>"test test test", "duedate_state"=>"1"}}}
    after_size = CalendarTodo.find(:all, :select => :id).size
    assert_equal (start_size+1), after_size
  end
  
  def test_edit_calendartodo
    time = Time.parse("2008-02-10 10:00:00")
    post(:create, {"body"=>{"entry_type"=>{"value"=>"calendar_todo"}, "selected_day"=>"2008-03-05", "calendar_todo"=>{"completed"=>"0", "notification_state"=>"0", "notification_value"=>"1", "notification_unit"=>"1", "priority"=>"0", "subject"=>"Todo Test", "duedate"=>{"month"=>time.month, "minute"=>time.min, "hour"=>time.hour, "day"=>time.day, "year"=>time.year, "suffix"=>(time.hour > 12 ? "PM" : "AM")}, "note"=>"test test test", "duedate_state"=>"1"}}})
    todo = CalendarTodo.find(:first)
    assert_equal time.getutc, todo.duedate.getutc
    id = todo.id
    new_time = Time.parse("2008-02-10 11:00:00") # One hour later
    new_title = "Edited " + todo.subject
    post(:edit, {"body"=>{"entry_type"=>{"value"=>"calendar_todo"}, "selected_day"=>"2008-03-03", "calendar_todo"=>{"completed"=>"0", "notification_state"=>"0", "notification_value"=>"1", "notification_unit"=>"1", "priority"=>"0", "id"=>"_#{id}", "subject"=>new_title, "duedate"=>{"month"=>new_time.month, "minute"=>new_time.min, "hour"=>new_time.hour, "day"=>new_time.day, "year"=>new_time.year, "suffix"=>(new_time.hour > 12 ? "PM" : "AM")}, "note"=>"test test test Edited", "duedate_state"=>"1"}}})
    todo.reload
    assert_equal new_title, todo.subject
    assert_equal new_time, todo.duedate
  end
    
  def test_add_notification
    assert true
  end
end
