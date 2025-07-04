desc "Tasks for implementing the calendar"
namespace "calendar" do
		desc "Move widget_instance_activities to activities"
    task :create_activities do
			for a in WidgetInstanceActivity.find(:all)
			    widget_instance = a.widget_instance rescue nil
			    if widget_instance
					  Activity.create(	:start => a.time,
  														:stop => a.time,
  														:activatable_id => a.widget_instance_id,
  														:activatable_type => "WidgetInstance",
  														:recurring_status => Activity::RECURRING_FALSE,
  														:status => widget_instance.status
  													)
				 end
			end
    end
    desc "Create Roles for Calendar beta testers"
    task :create_role do
      	Role.create(:name => "calendar_beta_tester role",
                    :status => Status::ACTIVE
                  	)
			 	Role.create(:name => "calendar_pending role",
			             	:status => Status::ACTIVE
			           		)
    end
    desc "Edit users timeformats"
    task :edit_users_timeformat do
     	require File.join(RAILS_ROOT,'vendor','plugins','validates_email_veracity_of','lib','vavo_extensions')
      users = User.find(:all)
  	  for user in users
      	if user.time_offset <= (-18000) && user.time_offset >= (-36000)
      	  # US time zone
      	  user.update_attribute(:pref_time, "n2s1d0t1w0o0")
      	else
      	  user.update_attribute(:pref_time, "n4s1d1t0w1o1")
      	end
			end
    end
end

