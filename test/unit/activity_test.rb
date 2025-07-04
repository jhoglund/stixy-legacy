require File.dirname(__FILE__) + '/../test_helper'

class ActivityTest < Test::Unit::TestCase
  
  def setup
    exemplify(Activity, 
      :start => Time.parse("2008-02-01 00:00 UTC"),
      :stop => Time.parse("2008-02-01 00:00 UTC"),
      :recurring_status => 1,
      :unit => Activity::MONTH,
      :frequency => 1,
      :status => Status::ACTIVE)
    
  end

  def test_recurring_each_month_starts_inside_range
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-05-20 00:00 UTC"), :stop => Time.parse("2008-05-27 10:03:27"))
    activities = []
    new_activity.recurrencies(Date.parse("2008-01-20"), Date.parse("2008-09-20")) do |activity|
      activities << activity
    end
    
    activities = activities.sort_by{|a| a.start }
    assert_equal Date.parse("2008-05-20").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2008-06-20").to_s, activities[1].start.to_d.to_s
    assert_equal Date.parse("2008-07-20").to_s, activities[2].start.to_d.to_s
    assert_equal Date.parse("2008-08-20").to_s, activities[3].start.to_d.to_s
    assert_equal Date.parse("2008-09-20").to_s, activities[4].start.to_d.to_s
    
    assert_equal 5, activities.size    
  end
  
  def test_recurring_each_month_starts_and_ends_outside_range
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-05-20 00:00 UTC"), :stop => Time.parse("2008-05-27 10:03:27"))
    activities = []
    new_activity.recurrencies(Date.parse("2008-06-20"), Date.parse("2008-09-19")) do |activity|
      activities << activity
    end
    assert_equal Date.parse("2008-06-20").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2008-07-20").to_s, activities[1].start.to_d.to_s
    assert_equal Date.parse("2008-08-20").to_s, activities[2].start.to_d.to_s
    assert_equal 3, activities.size
  end
  
  def test_recurring_earlier_same_month
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-01"), :recurring_status => "1", :unit => Activity::MONTH, :frequency => "3")
    activities = []
    new_activity.recurrencies(Date.parse("2008-05-02"), Date.parse("2008-06-02")) do |activity|
      activities << activity
    end
    assert activities.empty?
  end  
  
  def test_recurring_preserve_time
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-03-20 11:31:17 UTC"), :stop => Time.parse("2008-03-21 10:03:27 UTC"))
    activities = []
    new_activity.recurrencies(Date.parse("2008-06-20"), Date.parse("2008-09-19")) do |activity|
      activities << activity
    end
    assert_equal  Time.parse("2008-06-20 11:31:17 UTC"), activities[0].start
    assert_equal  Time.parse("2008-06-21 10:03:27 UTC"), activities[0].stop
  end
  
  def test_start_day_not_in_recurring_month
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-01-31 11:31:17 UTC"), :stop => Time.parse("2008-02-27 10:03:27 UTC"))
    activities = []
    new_activity.recurrencies(Date.parse("2008-04-28"), Date.parse("2008-04-30")) do |activity|
      activities << activity
    end
    assert_equal  Time.parse("2008-04-30 11:31:17 UTC"), activities[0].start
  end
  
  def test_last_day_en_month
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-01-31 11:31:17 UTC"), :stop => Time.parse("2008-02-27 10:03:27 UTC"))
    activities = []
    new_activity.recurrencies(Date.parse("2008-01-01"), Date.parse("2008-06-01")) do |activity|
      activities << activity
    end
    assert_equal  Time.parse("2008-01-31 11:31:17 UTC"), activities[0].start
    assert_equal  Time.parse("2008-02-29 11:31:17 UTC"), activities[1].start
    assert_equal  Time.parse("2008-03-31 11:31:17 UTC"), activities[2].start
    assert_equal  Time.parse("2008-04-30 11:31:17 UTC"), activities[3].start
    assert_equal  Time.parse("2008-05-31 11:31:17 UTC"), activities[4].start
    
    new_activity = Activity.create_exemplar(:start => Time.parse("2007-01-30 11:31:17 UTC"), :stop => Time.parse("2007-02-27 10:03:27 UTC"))
    activities = []
    new_activity.recurrencies(Date.parse("2007-01-01"), Date.parse("2007-06-01")) do |activity|
      activities << activity
    end
    assert_equal  Time.parse("2007-01-30 11:31:17 UTC"), activities[0].start
    assert_equal  Time.parse("2007-02-28 11:31:17 UTC"), activities[1].start
    assert_equal  Time.parse("2007-03-30 11:31:17 UTC"), activities[2].start
    assert_equal  Time.parse("2007-04-30 11:31:17 UTC"), activities[3].start
    assert_equal  Time.parse("2007-05-30 11:31:17 UTC"), activities[4].start
    
  end
  
  def test_recurring_every_27_month
    new_activity = Activity.create_exemplar(:start => Time.parse("2001-05-20 00:00 UTC"), :stop => Time.parse("2001-05-27 10:03:27"), :frequency => 27)
    activities = []
    new_activity.recurrencies(Date.parse("2008-01-20"), Date.parse("2010-09-20")) do |activity|
      activities << activity
    end
    
    activities = activities.sort_by{|a| a.start }
    assert_equal Date.parse("2008-02-20").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2010-05-20").to_s, activities[1].start.to_d.to_s
    
    assert_equal 2, activities.size    
  end
  
  def test_recurring_different_months
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-01"), :recurring_status => "1", :unit => Activity::MONTH, :frequency => "2")
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-02"), Date.parse("2008-03-31")) do |activity|
      activities << activity
    end
    assert activities.empty?
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-02"), Date.parse("2008-04-01")) do |activity|
      activities << activity
    end
    assert_equal Date.parse("2008-04-01").to_s, activities[0].start.to_d.to_s
    assert_equal 1, activities.size
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-01"), Date.parse("2008-04-01")) do |activity|
      activities << activity
    end
    assert_equal Date.parse("2008-02-01").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2008-04-01").to_s, activities[1].start.to_d.to_s
    assert_equal 2, activities.size
  end  
  
  def test_recurring_month_over_time_limit
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-01-30 11:31:17 UTC"), :stop => Time.parse("2008-02-02 10:03:27 UTC"))
    activities = []
    new_activity.recurrencies(Date.parse("2008-06-01"), Date.parse("2008-06-30")) do |activity|
      activities << activity
    end
    assert_equal  Time.parse("2008-05-30 11:31:17 UTC"), activities[0].start
    assert_equal  Time.parse("2008-06-30 11:31:17 UTC"), activities[1].start
    assert_equal 2, activities.size
  end
  
  def test_recurring_every_1_year
    new_activity = Activity.create_exemplar(:start => Time.parse("2001-05-20 00:00 UTC"), :stop => Time.parse("2001-05-27 10:03:27"), :frequency => 1, :unit => Activity::YEAR)
    activities = []
    new_activity.recurrencies(Date.parse("2002-05-20"), Date.parse("2004-09-20")) do |activity|
      activities << activity
    end
    activities = activities.sort_by{|a| a.start }
    assert_equal Date.parse("2002-05-20").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2003-05-20").to_s, activities[1].start.to_d.to_s
    assert_equal Date.parse("2004-05-20").to_s, activities[2].start.to_d.to_s
    assert_equal 3, activities.size    
  end
  
  def test_recurring_every_3_year
    new_activity = Activity.create_exemplar(:start => Time.parse("2001-05-20 00:00 UTC"), :stop => Time.parse("2001-05-27 10:03:27"), :frequency => 3, :unit => Activity::YEAR)
    activities = []
    new_activity.recurrencies(Date.parse("2001-05-20"), Date.parse("2013-09-20")) do |activity|
      activities << activity
    end
    activities = activities.sort_by{|a| a.start }
    assert_equal Date.parse("2001-05-20").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2004-05-20").to_s, activities[1].start.to_d.to_s
    assert_equal Date.parse("2007-05-20").to_s, activities[2].start.to_d.to_s
    assert_equal Date.parse("2010-05-20").to_s, activities[3].start.to_d.to_s
    assert_equal Date.parse("2013-05-20").to_s, activities[4].start.to_d.to_s
    
    assert_equal 5, activities.size    
  end
  
  def test_recurring_different_years
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-01"), :recurring_status => "1", :unit => Activity::YEAR, :frequency => "3")
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-02"), Date.parse("2008-06-02")) do |activity|
      activities << activity
    end
    assert activities.empty?
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-01"), Date.parse("2011-01-31")) do |activity|
      activities << activity
    end
    assert_equal Date.parse("2008-02-01").to_s, activities[0].start.to_d.to_s
    assert_equal 1, activities.size
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-01"), Date.parse("2011-02-01")) do |activity|
      activities << activity
    end
    assert_equal Date.parse("2008-02-01").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2011-02-01").to_s, activities[1].start.to_d.to_s
    assert_equal 2, activities.size
  end  
  
  
  def test_recurring_every_5_week
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-05-20 00:00 UTC"), :stop => Time.parse("2008-05-27 10:03:27"), :frequency => 5, :unit => Activity::WEEK)
    activities = []
    new_activity.recurrencies(Date.parse("2008-03-20"), Date.parse("2008-08-20")) do |activity|
      activities << activity
    end
    activities = activities.sort_by{|a| a.start }
    assert_equal Date.parse("2008-05-20").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2008-06-24").to_s, activities[1].start.to_d.to_s
    assert_equal Date.parse("2008-07-29").to_s, activities[2].start.to_d.to_s
    
    assert_equal 3, activities.size    
  end
  
  def test_recurring_different_weeks
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-01"), :recurring_status => "1", :unit => Activity::WEEK, :frequency => "2")
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-02"), Date.parse("2008-02-14")) do |activity|
      activities << activity
    end
    assert activities.empty?
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-02"), Date.parse("2008-02-15")) do |activity|
      activities << activity
    end
    assert_equal Date.parse("2008-02-15").to_s, activities[0].start.to_d.to_s
    assert_equal 1, activities.size
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-01"), Date.parse("2008-02-15")) do |activity|
      activities << activity
    end
    assert_equal Date.parse("2008-02-01").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2008-02-15").to_s, activities[1].start.to_d.to_s
    assert_equal 2, activities.size
  end  
  
  def test_recurring_every_week
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-01"), :recurring_status => "1", :unit => Activity::WEEK, :frequency => "1")
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-02"), Date.parse("2008-02-15")) do |activity|
      activities << activity
    end
    assert_equal Date.parse("2008-02-08").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2008-02-15").to_s, activities[1].start.to_d.to_s
    assert_equal 2, activities.size
  end  
  
  def test_recurring_every_day
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-05-20 00:00 UTC"), :stop => Time.parse("2008-05-27 10:03:27"), :frequency => 1, :unit => Activity::DAY)
    activities = []
    new_activity.recurrencies(Date.parse("2008-05-18"), Date.parse("2008-05-24")) do |activity|
      activities << activity
    end
    activities = activities.sort_by{|a| a.start }
    assert_equal Date.parse("2008-05-20").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2008-05-21").to_s, activities[1].start.to_d.to_s
    assert_equal Date.parse("2008-05-22").to_s, activities[2].start.to_d.to_s
    assert_equal Date.parse("2008-05-23").to_s, activities[3].start.to_d.to_s
    assert_equal Date.parse("2008-05-24").to_s, activities[4].start.to_d.to_s
    
    assert_equal 5, activities.size    
  end
  
  def test_recurring_every_73_day
    new_activity = Activity.create_exemplar(:start => Time.parse("2001-05-20 00:00 UTC"), :stop => Time.parse("2001-05-27 10:03:27 UTC"), :frequency => 73, :unit => Activity::DAY)
    activities = []
    new_activity.recurrencies(Date.parse("2006-05-18"), Date.parse("2007-04-24")) do |activity|
      activities << activity
    end
    activities = activities.sort_by{|a| a.start }
    assert_equal Date.parse("2006-05-19").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2006-07-31").to_s, activities[1].start.to_d.to_s
    assert_equal Date.parse("2006-10-12").to_s, activities[2].start.to_d.to_s
    assert_equal Date.parse("2006-12-24").to_s, activities[3].start.to_d.to_s
    assert_equal Date.parse("2007-03-07").to_s, activities[4].start.to_d.to_s
    
    assert_equal 5, activities.size    
  end
  
  def test_recurring_different_days
    new_activity = Activity.create_exemplar(:start => Time.parse("2008-02-01"), :stop => Time.parse("2008-02-01"), :recurring_status => "1", :unit => Activity::DAY, :frequency => "2")
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-02"), Date.parse("2008-02-02")) do |activity|
      activities << activity
    end
    assert activities.empty?
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-02"), Date.parse("2008-02-03")) do |activity|
      activities << activity
    end
    assert_equal Date.parse("2008-02-03").to_s, activities[0].start.to_d.to_s
    assert_equal 1, activities.size
    activities = []
    new_activity.recurrencies(Date.parse("2008-02-01"), Date.parse("2008-02-03")) do |activity|
      activities << activity
    end
    assert_equal Date.parse("2008-02-01").to_s, activities[0].start.to_d.to_s
    assert_equal Date.parse("2008-02-03").to_s, activities[1].start.to_d.to_s
    assert_equal 2, activities.size
  end  
  
  def test_recurring_offset
    assert_equal Activity.first_recurrence(Time.parse("2001-05-20 00:00 UTC"), Time.parse("2006-05-18 00:00 UTC"), 73, Activity::DAY), Time.parse("2006-05-19 00:00 UTC")
    assert_equal Activity.first_recurrence(Time.parse("2008-05-20 00:00 UTC"), Time.parse("2006-05-18 00:00 UTC"), 5, Activity::WEEK), Time.parse("2008-05-20 00:00 UTC")
    assert_equal Activity.first_recurrence(Time.parse("2008-05-20 00:00 UTC"), Time.parse("2008-06-10 00:00 UTC"), 5, Activity::WEEK), Time.parse("2008-06-24 00:00 UTC")
    assert_equal Activity.first_recurrence(Time.parse("2001-05-20 00:00 UTC"), Time.parse("2001-11-20 00:00 UTC"), 7, Activity::MONTH), Time.parse("2001-12-20 00:00 UTC")
    assert_equal Activity.first_recurrence(Time.parse("2001-05-20 00:00 UTC"), Time.parse("2001-12-20 00:00 UTC"), 7, Activity::MONTH), Time.parse("2001-12-20 00:00 UTC")
    assert_equal Activity.first_recurrence(Time.parse("2001-05-20 00:00 UTC"), Time.parse("2003-12-20 00:00 UTC"), 2, Activity::YEAR), Time.parse("2005-05-20 00:00 UTC")
  end
  
end
