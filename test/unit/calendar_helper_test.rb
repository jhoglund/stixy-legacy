require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../app/helpers/calendar_helper'
include CalendarHelper

require 'calendar_controller'

# Re-raise errors caught by the controller.
class CalendarController; def rescue_action(e) raise e end; end

class CalendarHelperTest < Test::Unit::TestCase
   
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
    User.delete_all
    Activity.delete_all
    CalendarEntry.delete_all
    Notification.delete_all
    Member.delete_all
    Priority.delete_all
  end
  
  def test_activities
    CalendarEntry.create_exemplar(:subject => "One day",:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-01"), :users => [@jonas])
    CalendarEntry.create_exemplar(:subject => "Two days",:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-02"), :users => [@jonas])
    CalendarEntry.create_exemplar(:subject => "Three days",:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-03"), :users => [@jonas])
    CalendarEntry.create_exemplar(:subject => "Four days",:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-04"), :users => [@jonas])
    CalendarEntry.create_exemplar(:subject => "Five days",:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-05"), :users => [@jonas])
    CalendarEntry.create_exemplar(:subject => "Six days",:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-06"), :users => [@jonas])
    CalendarEntry.create_exemplar(:subject => "Seven days",:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-07"), :users => [@jonas])
    CalendarEntry.create_exemplar(:subject => "Eight days",:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-08"), :users => [@jonas])
    @params = {:calendar_date => Date.civil(2008,02,01)}
    @session = {:calendars => {}}
    @current_user = @jonas
  	activities()
  end
  
  private
  
  def params
	  return @params
	end
	
	def session
	  return @session
  end
  
  def current_user
    return @current_user
  end
end
