require File.dirname(__FILE__) + '/../test_helper'
require 'notifier'

class WidgetTodoReminderTest < Test::Unit::TestCase
#  fixtures :users, :roles, :boards, :boardusers, :widget_instances, :widget_instance_activities, :widgets, :widget_todo_notifications
#  
#  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
#  CHARSET = "utf-8"
#
#  include ActionMailer::Quoting
#
#  def setup
#    ActionMailer::Base.delivery_method = :test
#    ActionMailer::Base.perform_deliveries = true
#    ActionMailer::Base.deliveries = []
#
#    @expected = TMail::Mail.new
#    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
#  end
#  
#  def test_send_reminder
#    time = Time.now
#    reminders = UserNotification.pending(time)
#    
#    # Test to see if the right number of reminders where fetched
#    assert_equal 6, reminders.size
#    
#    # Test to see if the right reminders where fetched
#    [[1,2],[1,3],[3,2],[3,3],[3,4],[3,5]].each_with_index do |widget_user,i|
#      assert_equal widget_user.first, reminders[i].widget_instance_id, "failed on iteration #{i}"
#      assert_equal widget_user.last, reminders[i].user.id, "failed on iteration #{i}"
#    end
#    
#    # Test to see if the reminders email are created and the content is right (everything except the actual delivery)
#    reminders.each do |reminder|
#      widget = WidgetTodo.find(reminder.widget_instance_id)
#      assert_kind_of WidgetTodo, widget
#      response = WidgetTodoReminder.deliver_notifier_mail(widget, reminder)
#      assert_match "[Stixy] Reminder", response.subject
#      assert_equal [reminder.user.email], response.to
#      assert_equal ["reminder@stixy.com"], response.from
#    end
#    UserNotification.deactivate(time)
#    
#    # Test to see if reminders sent were deactivated
#    assert_equal 2, UserNotification.find_all_by_status(Status::PENDING).size
#    
#    # Same test as above, but for the two remining reminders
#    time = 4.day.from_now
#    reminders = UserNotification.pending(time)
#    
#    [[2,3],[2,4]].each_with_index do |widget_user,i|
#      assert_equal widget_user.first, reminders[i].widget_instance_id, "failed on iteration #{i}"
#      assert_equal widget_user.last, reminders[i].user.id, "failed on iteration #{i}"
#    end
#    
#    time = 3.day.from_now
#    reminders = UserNotification.pending(time)
#    assert_equal 2, reminders.size
#    reminders.each do |reminder|
#      widget = WidgetTodo.find(reminder.widget_instance_id)
#      assert_kind_of WidgetTodo, widget
#      response = WidgetTodoReminder.deliver_notifier_mail(widget, reminder)
#      assert_match "[Stixy] Reminder", response.subject
#      assert_equal [reminder.user.email], response.to
#      assert_equal ["reminder@stixy.com"], response.from
#    end
#    UserNotification.deactivate(time)
#    assert_equal 0, UserNotification.find_all_by_status(Status::PENDING).size
#    reminders = UserNotification.pending(100.day.from_now)
#    assert_equal 0, reminders.size
#  end
#  
#  def test_disable_user_and_board
#    time = Time.now
#    # Test to see if the right number of reminders where fetched
#    assert_equal 6, UserNotification.pending(time).size
#    users(:adam).update_attribute(:status, Status::DISABLED)
#    assert_equal 4, UserNotification.pending(time).size
#    boards(:first).update_attribute(:status, Status::DISABLED)
#    assert_equal 0, UserNotification.pending(time).size
#  end
#  
end
