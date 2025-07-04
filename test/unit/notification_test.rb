require File.dirname(__FILE__) + '/../test_helper'

class NotificationTest < Test::Unit::TestCase
  fixtures :users, :boards, :boardusers, :abstract_calendars, :members, :notifications, :activities
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  def test_send_notification_all_users
    test_notification_size(2,0)
    Notification.deliver(notifications(:all_users).time)
    assert_equal 2, ActionMailer::Base.deliveries.size
    test_notification_size(1,1)
    entry = abstract_calendars(:calendar_with_notification_all_users)
    test_mail(ActionMailer::Base.deliveries.first, entry, entry.members[0].user)
    test_mail(ActionMailer::Base.deliveries.last, entry, entry.members[1].user)
  end
  
  def test_send_notification_wrong_time
    test_notification_size(2,0)
    Notification.deliver(notifications(:all_users).time-1)
    assert_equal 0, ActionMailer::Base.deliveries.size
    test_notification_size(2,0)
  end

  def test_send_notification_selected
    test_notification_size(2,0)
    notifications(:all_users).update_attribute(:status, Status::FINISHED)
    Notification.deliver(notifications(:selected_user).time)
    assert_equal 1, ActionMailer::Base.deliveries.size
    test_notification_size(0,2)
    entry = abstract_calendars(:calendar_with_notification_one_user)
    test_mail(ActionMailer::Base.deliveries.last, entry, entry.members[0].user)
  end
  
  def test_send_notification_for_recurring
    Notification.delete_all
    ce = CalendarEntry.new(
      :activity => Activity.create!(:start =>  Time.parse("2008-02-27 10:00:00 UTC"), :recurring_status => 1, :unit => Activity::DAY, :frequency => 3),
      :notification => Notification.create!(:time =>  Time.parse("2008-02-26 10:00:00 UTC"), :status => Status::PENDING_RECURRING)
    )
    ce.instance_variable_set("@notification_state", "1")
    ce.save!
    ce = CalendarEntry.find(ce.id)
    today = Time.now
    Notification.connection.update("update notifications set time = '2008-02-26 10:00:00' where id = #{ce.notification.id}")
    ce =  CalendarEntry.find(ce.id)
    assert_equal Time.parse('2008-02-26 10:00:00').to_d.to_s, ce.notification.time.to_d.to_s
    assert ce.notification.time < today
    Notification.deliver(Time.parse('2008-02-27 10:00:00'))
    ce = CalendarEntry.find(ce.id)
    assert_equal Time.parse('2008-02-29 10:00:00').to_d.to_s, ce.notification.time.to_d.to_s 
  end
  
 
  private
  
  def test_notification_size(pending=0,finished=0)
    assert_equal pending, Notification.count(:conditions => "status = #{Status::PENDING}")
    assert_equal finished, Notification.count(:conditions => "status = #{Status::FINISHED}")
  end
  
  def test_mail mail, entry, user
    assert_equal [user.email], mail.to
    assert mail.subject =~ Regexp.new(entry.subject)
    assert mail.body =~ Regexp.new(entry.note)
  end
  
end
