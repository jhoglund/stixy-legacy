require File.dirname(__FILE__) + '/../test_helper'

class AbstractCalendarTest < Test::Unit::TestCase
  fixtures :roles
  def setup
     exemplify(User, :time_offset => 3600, :description => "")
     @jonas  = User.create_exemplar(:pwd => "password", :login => "jonas@test.com", :roles => [Role.find(3)])
     @daniel = User.create_exemplar(:pwd => "password", :login => "daniel@test.com", :roles => [Role.find(3)])
     @tobias = User.create_exemplar(:pwd => "password", :login => "tobias@test.com", :roles => [Role.find(3)])
     @otto   = User.create_exemplar(:pwd => "password", :login => "otto@test.com", :roles => [Role.find(3)])
     @maria  = User.create_exemplar(:pwd => "password", :login => "maria@test.com", :roles => [Role.find(3)])
     
     exemplify(Activity, 
       :start => Time.parse("2008-02-01"),
       :stop => Time.parse("2008-02-01"),
       :status => Status::ACTIVE)
             
     exemplify(Notification, 
       :time => Time.parse("2008-01-01"),
       :status => Status::PENDING)
     
     exemplify(Member)
     
     exemplify(CalendarEntry, 
       :auto_id => :subject, 
       :auto_id => :note, 
       :auto_id => :location, 
       :status => Status::ACTIVE)
       
     exemplify(CalendarTodo, 
       :auto_id => :subject, 
       :auto_id => :note, 
       :status => Status::ACTIVE)
     
     @todo = CalendarTodo.exemplar(:priority => Priority::LOW, :duedate => Time.parse("2008-02-01"), :duedate_state => Status::ACTIVE)
  
  end
  
  def teardown
    ActionMailer::Base.deliveries = []
    User.delete_all
    Activity.delete_all
    CalendarEntry.delete_all
    Notification.delete_all
    Member.delete_all
    Priority.delete_all
  end
  
  ######################
  # CalendarTodo tests #
  ######################
  
  def test_create_todo
    todo = CalendarTodo.exemplar(:priority => Priority::MEDIUM, :duedate => Time.parse("2008-02-01"), :duedate_state => Status::ACTIVE)
	  assert_equal true, todo.save!
	  todo = CalendarTodo.find(todo.id)
	  assert_equal Priority::MEDIUM, todo.priority
	  assert_equal "Medium", todo.priority(:name)
	  assert_equal Time.parse("2008-02-01"), todo.duedate
	  assert_equal true, todo.duedate?
	  assert_equal false, todo.completed?
	end
	
	def test_update_todo
    assert_equal true, @todo.update_attributes({:priority => Priority::HIGH, :duedate_state => Status::DISABLED, :status => Status::FINISHED})
	  todo = CalendarTodo.find(@todo.id)
    assert_equal Priority::HIGH, todo.priority
	  assert_equal false, todo.duedate?
	  assert_equal true, todo.completed?
	end
  
  #######################
  # CalendarEntry tests #
  #######################
  
  def test_recurring_events_month
  	entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-01"), :users => [@jonas], :recurring => { :status => "1", :unit => Activity::MONTH, :frequency => "3" })
  	entry = CalendarEntry.find(entry.id)
  	assert_equal true, entry.activity.recurring?
  	assert_equal 0, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-05-02"), Date.parse("2008-05-02"), :build_recurring => true).size
  	assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-05-01"), Date.parse("2008-05-01"), :build_recurring => true).size
  	assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-05-01"), Date.parse("2008-07-31"), :build_recurring => true).size
  	assert_equal 2, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-05-01"), Date.parse("2008-08-01"), :build_recurring => true).size
  	assert_equal 6, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2009-05-01"), Date.parse("2010-08-01"), :build_recurring => true).size
  end
  
  def test_recurring_events_split_month
  	entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-01-29"), :stop => Time.parse("2008-02-02"), :users => [@jonas], :recurring => { :status => "1", :unit => Activity::MONTH, :frequency => "3" })
  	entry = CalendarEntry.find(entry.id)
  	assert_equal true, entry.activity.recurring?
  	assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-01-28"), Date.parse("2008-02-29"), :build_recurring => true).size
  	assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-01-29"), Date.parse("2008-02-29"), :build_recurring => true).size
  	assert_equal 0, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-01-28"), Date.parse("2008-01-28"), :build_recurring => true).size
  	assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-01-28"), Date.parse("2008-01-29"), :build_recurring => true).size
  	assert_equal 2, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-01-28"), Date.parse("2008-04-29"), :build_recurring => true).size
  end

  def test_recurring_events_day
  	entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-03"), :users => [@jonas], :recurring => { :status => "1", :unit => Activity::DAY, :frequency => "5" })
  	entry = CalendarEntry.find(entry.id)
  	assert_equal true, entry.activity.recurring?
    assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-02-01"), Date.parse("2008-02-05"), :build_recurring => true).size
  	assert_equal 2, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-02-01"), Date.parse("2008-02-06"), :build_recurring => true).size
  	assert_equal 9, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-02-01"), Date.parse("2008-03-16"), :build_recurring => true).size
  	entries = CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-02-01"), Date.parse("2008-03-17"), :build_recurring => true)
  	assert_equal 10, entries.size
  	assert_equal Date.parse("2008-03-17").to_s, entries.last.start.to_d.to_s
  	assert_equal Date.parse("2008-03-19").to_s, entries.last.stop.to_d.to_s
  end
  
  def test_recurring_events_year
  	entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-01"), :users => [@jonas], :recurring => { :status => "1", :unit => Activity::YEAR, :frequency => "5" })
  	assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-02-01"), Date.parse("2008-03-01"), :build_recurring => true).size
  	assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-02-01"), Date.parse("2012-02-01"), :build_recurring => true).size
  	assert_equal 2, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-02-01"), Date.parse("2013-02-01"), :build_recurring => true).size
  end
  
  def test_recurring_events_week
  	entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-04-11"), :stop => Time.parse("2008-04-11"), :users => [@jonas], :recurring => { :status => "1", :unit => Activity::WEEK, :frequency => "1" })
  	assert_equal 2, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-04-11"), Date.parse("2008-04-18"), :build_recurring => true).size
  	assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-04-18"), Date.parse("2008-04-18"), :build_recurring => true).size
  	assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-05-02"), Date.parse("2008-05-02"), :build_recurring => true).size
  	assert_equal 2, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-05-02"), Date.parse("2008-05-09"), :build_recurring => true).size
  end
  
  
  def test_recurring_events_disable
  	entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-01"), :users => [@jonas], :recurring => { :status => "1", :unit => Activity::YEAR, :frequency => "5" })
  	assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-02-01"), Date.parse("2008-03-01"), :build_recurring => true).size
  	entry.update_attributes(:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-01"), :users => [@jonas], :recurring => { :status => "0", :unit => Activity::YEAR, :frequency => "5" })
    entry = CalendarEntry.find(entry.id)
  	assert_equal false, entry.activity.recurring?
  	assert_equal 1, CalendarEntry.get_for_calendar(@jonas.id, Date.parse("2008-02-01"), Date.parse("2013-02-01"), :build_recurring => true).size
  end
  
  ########################
  ## Notification tests ##
  ########################
  
  def test_set_and_deactivate_user_account
    # CalendarEntry with notification for selected users. Deactivate user account for one of the users
    entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :users => [@jonas, @daniel, @tobias],  :notification_value => "3", :notification_unit => Notification::HOUR, :notification_state => "1", :notification_members => [@jonas.id, @daniel.id,@tobias.id])
    entry = CalendarEntry.find(entry.id)
    assert_equal 3, entry.members.length
    assert_not_nil entry.members[0].notification
    assert_not_nil entry.members[1].notification
    assert_not_nil entry.members[2].notification
    # Deactivate both the members for the user and the user. 
    # This is usally handled by the controller, but we needs to do both when testing
    @tobias.memberships.deactivate!
    @tobias.deactivate!
    entry = CalendarEntry.find(entry.id)
    assert_equal 2, entry.members.length
    Notification.deliver(Time.parse("2008-02-01"))
    assert_equal 2, ActionMailer::Base.deliveries.size
    assert_equal [@jonas.email], ActionMailer::Base.deliveries.first.to
    assert_equal [@daniel.email], ActionMailer::Base.deliveries.last.to
  end

  def test_set_and_disable_all
    # CalendarEntry with notification for all. Disable notification
    entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :users => [@jonas], :notification => Notification.create_exemplar(:time => Time.parse("2008-01-01")))
    entry = CalendarEntry.find(entry.id)
    entry.attributes = { :notification_state => "0", :notification_value => "1", :notification_unit => Notification::HOUR }
    assert_equal true, entry.save!
    entry.reload
    assert_equal true, entry.notification.disabled?
  end
  
  def test_set_and_remove_event
    # CalendarEntry with notification for all. Disable notification
    entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :users => [@jonas], :notification => Notification.create_exemplar(:time => Time.parse("2008-01-01")))
    entry = CalendarEntry.find(entry.id)
    assert_equal 0, Member.count(:all, :conditions => "membershipable_id=#{entry.id} and membershipable_type='AbstractCalendar' and status=0")
    assert_equal 0, Activity.count(:all, :conditions => "activatable_id=#{entry.id} and activatable_type='AbstractCalendar' and status=0")
    assert_equal 0, Notification.count(:all, :conditions => "noteable_id=#{entry.id} and noteable_type='AbstractCalendar' and status=0")
    assert_equal true, entry.remove!
    entry = CalendarEntry.find(entry.id)
    assert_equal 0, entry.status
    assert_equal 1, Member.count(:all, :conditions => "membershipable_id=#{entry.id} and membershipable_type='AbstractCalendar' and status=0")
    assert_equal 1, Activity.count(:all, :conditions => "activatable_id=#{entry.id} and activatable_type='AbstractCalendar' and status=0")
    assert_equal 1, Notification.count(:all, :conditions => "noteable_id=#{entry.id} and noteable_type='AbstractCalendar' and status=0")
  end
  
  def test_set_and_disable_members
    # CalendarEntry with notification for all. Disable notification
    entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :users => [@jonas,@daniel,@tobias], :notification_value => "3", :notification_unit => Notification::HOUR, :notification_state => "1", :notification_members => [@jonas.id, @daniel.id])
    entry = CalendarEntry.find(entry.id)
    entry.attributes = { :notification_state => "0", :notification_value => "1", :notification_unit => Notification::HOUR, :notification_members => [@jonas.id, @daniel.id] }
    assert_equal true, entry.save!
    entry.reload
    assert_equal true, entry.members[0].notification.disabled?
    assert_equal true, entry.members[1].notification.disabled?
    assert_nil entry.members[2].notification
  end
  
  def test_set_and_send_reminders_to_all
    # CalendarEntry with 1 member, and notification to all
    entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :users => [@jonas], :notification => Notification.create_exemplar(:time => Time.parse("2008-01-01")))
    Notification.deliver(Time.parse("2008-01-01"))
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal ActionMailer::Base.deliveries.first.to, [entry.members[0].user.email]
  end
  
  def test_set_and_send_reminders_to_all_3_members
    # CalendarEntry with 3 members, and notification to all
    entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :users => [@jonas, @daniel, @tobias], :notification => Notification.create_exemplar(:time => Time.parse("2008-01-01")))
    Notification.deliver(Time.parse("2008-01-01"))
    assert_equal 3, ActionMailer::Base.deliveries.size
    assert_not_equal ActionMailer::Base.deliveries.first.to, ActionMailer::Base.deliveries.last.to
  end
  
  def test_set_and_send_reminders_to_2_out_of_3
    # CalendarEntry with 3 members, and notification to 2 members
    entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :users => [@jonas, @daniel, @tobias], :notification_value => "3", :notification_unit => Notification::HOUR, :notification_state => "1", :notification_members => [@jonas.id, @daniel.id])
    Notification.deliver(Time.parse("2008-02-01"))
    assert_equal 2, ActionMailer::Base.deliveries.size
    assert_equal ActionMailer::Base.deliveries.first.to, [@jonas.email]
    assert_equal ActionMailer::Base.deliveries.last.to, [@daniel.email]
  end
  
  def test_set_and_send_reminders_all_after_reset
    # CalendarEntry with 3 members, and notification to 2 members
    entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :users => [@jonas, @daniel, @tobias], :notification_value => "3", :notification_unit => Notification::DAY, :notification_state => "1", :notification_members => [@jonas.id, @daniel.id])
    entry = CalendarEntry.find(entry.id)
    entry.attributes = { :notification_state => "1", :notification_value => "1", :notification_unit => Notification::HOUR }
    assert_equal true, entry.save!
    entry.reload
    assert_not_nil entry.notification
    Notification.deliver(Time.parse("2008-02-01"))
    assert_equal 3, ActionMailer::Base.deliveries.size
  end
  
  def test_read_notification_attributes
    # Create new CalenderEntry and set reminder to one DAY earlier
    entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01"), :notification => Notification.create_exemplar(:time => Time.parse("2008-01-01"), :value => 31, :unit => Notification::DAY))
    assert_equal entry.notification_unit, Notification::DAY
    assert_equal entry.notification_value, 31 
    assert_equal entry.notification_state, true 
    assert_equal entry.notify?, true 
  
    # Create new CalenderEntry and set reminder to 3 hours earlier
    entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01 10:00"), :notification => Notification.create_exemplar(:time => Time.parse("2008-02-01 07:00"), :value => 3, :unit => Notification::HOUR))
    assert_equal entry.notification_unit, Notification::HOUR
    assert_equal entry.notification_value, 3 
  
    # Create new CalenderEntry and set reminder to 7 minutes earlier
    entry = CalendarEntry.create_exemplar(:start => Time.parse("2008-02-01 10:07"), :notification => Notification.create_exemplar(:time => Time.parse("2008-02-01 10:00"), :value => 7, :unit => Notification::MINUTE))
    assert_equal entry.notification_unit, Notification::MINUTE
    assert_equal entry.notification_value, 7 
  end
  
  def test_update
    entry = CalendarEntry.exemplar
    entry.attributes = {
      :start => { :month => "02", :minute => "20", :hour => "03", :day => "07", :year => "2008", :suffix => "PM" }, 
      :stop => { :month => "02", :minute => "20", :hour => "03", :day => "24", :year => "2008", :suffix => "PM" }, 
      :notification_state => "1", 
      :notification_value => "1", 
      :notification_unit => Notification::HOUR, 
      :recurring => { :status=>"0", :unit=>"1", :frequency=>"1" }
    }
	  assert_equal true, entry.save!
	end
	
	def test_set_members
	  # Create new calendar entry
    entry = CalendarEntry.new
    entry.attributes = {
      :start => { :month => "02", :minute => "20", :hour => "03", :day => "07", :year => "2008", :suffix => "PM" }, 
      :stop => { :month => "02", :minute => "20", :hour => "03", :day => "24", :year => "2008", :suffix => "PM" }, 
      :users => [@jonas, @daniel, @tobias],
      :recurring => { :status => "0", :unit => "1", :frequency => "1" }
    }
    assert_equal true, entry.save!
	  entry.reload
	  
	  # Set notifications for Jonas and Daniel
    entry.attributes = {
      :notification_state => "1", 
      :notification_value => "1", 
      :notification_unit => Notification::DAY,
      :notification_members => [@jonas.id, @daniel.id] 
    }
    assert_equal true, entry.save!
    entry.reload
    assert_not_nil entry.members[0].notification
    assert_not_nil entry.members[1].notification
    assert_nil entry.members[2].notification
    assert_nil entry.notification
    assert_equal @jonas.adjusted_time(Time.local(2008,02,06,15,20)).getutc, entry.members.first.notification.time
    
    # Set notification for all users
    entry = CalendarEntry.find(entry.id)
    entry.attributes = {
      :notification_state => "1", 
      :notification_value => "1", 
      :notification_unit => Notification::HOUR
    }
	  assert_equal true, entry.save!
    entry.reload
    assert_nil entry.members[0].notification
    assert_nil entry.members[1].notification
    assert_nil entry.members[2].notification
    assert_not_nil entry.notification
    
    # Reset notification for Jonas and Daniel only
    entry.attributes = {
      :notification_state => "1", 
      :notification_value => "1", 
      :notification_unit => Notification::DAY,
      :notification_members => [@jonas.id, @daniel.id] 
    }
    assert_equal true, entry.save!
    entry.reload
    assert_not_nil entry.members[0].notification
    assert_not_nil entry.members[1].notification
    assert_nil entry.members[2].notification
    assert_nil entry.notification
    assert_equal @jonas.adjusted_time(Time.local(2008,02,06,15,20)).getutc, entry.members.first.notification.time
    
	end
  
	
	def test_create_read_update_delete

		# create a brand new message
		calendarentry1 = CalendarEntry.new(	:subject => 'Testentry1', 
																				:note => 'Testentry1 from unittest',
																				:location => 'Karlshamn',
																				:status => Status::ACTIVE,
																				:type => CalendarEntry,
																				:current_user => @jonas)

		time = Time.now
		activity1 = Activity.new(:start => time,
														:stop => time,
														:recurring_status => Activity::RECURRING_FALSE,
														:status => Status::ACTIVE)


		# create member		
		member1 = Member.new
		member1.user = @jonas

		# save it
		assert calendarentry1.save
		
		# set activity for calendarentry1 
		assert calendarentry1.activity = activity1

		# test save activity
		assert activity1.save

		# set member fpr calendarentry1
		assert calendarentry1.members << member1

		# save member1
		assert member1.save

		# read it back
		calendarentry2 = CalendarEntry.find(calendarentry1.id)
		activity2 = Activity.find(activity1.id)

		# Test activatable is set correct		
		assert_equal activity2.activatable_id, calendarentry2.id
		assert_equal activity2.activatable_type, "AbstractCalendar"
				
		# compare the subjects
		assert_equal calendarentry1.subject, calendarentry2.subject

		assert_equal 1, calendarentry2.members.size

		# change the subject
		calendarentry2.subject = 'Some new subject'
		calendarentry2.current_user = @jonas

		# save the changes
		assert calendarentry2.save

		# the message gets killeds
		assert calendarentry2.destroy
	end

	def test_incorrect_time

		# create a brand new message
		calendarentry1 = CalendarEntry.new(	:subject => 'Testentry1', 
																				:note => 'Testentry1 from unittest',
																				:location => 'Karlshamn',
																				:status => Status::ACTIVE,
																				:type => CalendarEntry,
																				:current_user => @jonas)

		time = "Error"
		activity1 = Activity.new(:start => time,
														:stop => time,
														:recurring_status => Activity::RECURRING_FALSE,
														:status => Status::ACTIVE)
    
		# save it
		assert calendarentry1.save!
		
		# set activity for calendarentry1 
		assert calendarentry1.activity = activity1
	  
		# test save, should be false because wrong time
		assert_equal false, activity1.save
	end
	
	private
	
end
