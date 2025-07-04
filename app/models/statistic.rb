class Statistic < ActiveRecord::Base

  def self.get date= Time.new
    list = {:rows => Array.new }
    Date.civil(date.year, date.month, 1).upto(Date.civil(date.year, date.month, -1)) do |cdate|
      list[:rows] << {
        :date => "#{cdate}",
        :new_users => count_by_sql("select count(*) from users where date(created_on)='#{cdate}'"),
        :new_invites => count_by_sql("select count(*) from invites where date(created_on)='#{cdate}'"),
        :new_user_registration => count_by_sql("select count(*) from users where date(created_on)='#{cdate}' and created_by_id = 1"),
        :new_user_invites => count_by_sql("select count(*) from users where date(created_on)='#{cdate}' and created_by_id != 1"),
        :active_users => count_by_sql("select count(*) from users where (date(created_on)='#{cdate}' or date(updated_on)='#{cdate}' or date(last_login_date)='#{cdate}') and status=1")
      }
    end
    #start_user_count = count_by_sql("select count(*) from users where date(created_on)<'#{Date.civil(date.year, date.month, 1)}' and status=1")
    end_user_count = count_by_sql("select count(*) from users where date(created_on)<='#{Date.civil(date.year, date.month, -1)}' and status=1")
    #start_active_user_count = count_by_sql("select count(*) from users where (date(created_on)>='#{date<<1}' or date(last_login_date)>='#{date<<1}') and (date(created_on)<'#{date << 2}' or date(last_login_date)<'#{date<<2}') and status=1")
    #end_active_user_count = count_by_sql("select count(*) from users where (date(created_on)>='#{date}' or date(last_login_date)>='#{date}') and (date(created_on)>='#{date<<1}' or date(last_login_date)>='#{date<<1}') and status=1")
    #new_user_count = end_user_count - start_user_count
    #start_user_invites_count = count_by_sql("select count(*) from users where date(created_on)<'#{Date.civil(date.year, date.month, 1)}' and status=1 and created_by_id!=1")
    #end_user_invites_count = count_by_sql("select count(*) from users where date(created_on)<='#{Date.civil(date.year, date.month, -1)}' and status=1 and created_by_id!=1")
    #new_user_invites_count = end_user_invites_count - start_user_invites_count
    #new_user_registration_count = (end_user_count - start_user_count)-(end_user_invites_count - start_user_invites_count)
    #new_user_growth = ((new_user_count.to_f / start_user_count.to_f)*100).to_i
    #new_user_invites_growth = ((new_user_invites_count.to_f / start_user_count.to_f)*100).to_i
    #new_user_registration_growth = ((new_user_count.to_f-new_user_invites_count.to_f / start_user_count.to_f)*100).to_i
    #user_atteration = (((start_user_count.to_f-count_by_sql("select count(*) from users where date(created_on)<'#{date}' and date(last_login_date)>='#{date}' and status=1").to_f)/start_user_count.to_f)*100).to_i
    #new_user_per_user = new_user_count>0 ? (((new_user_count.to_f/start_active_user_count.to_f)*100).to_i.to_f/100) : 0;
    
    list[:summary] = {
      #:start_user_count => start_user_count,
      :end_user_count => end_user_count#,
      #:start_active_user_count => start_active_user_count,
      #:end_active_user_count => end_active_user_count,
      #:new_user_count => new_user_count,
      #:new_user_invites_count => new_user_invites_count,
      #:new_user_registration_count => new_user_registration_count,
      #:new_user_growth => new_user_growth,
      #:new_user_invites_growth => new_user_invites_growth,
      #:new_user_registration_growth => new_user_growth-new_user_invites_growth,
      #:new_user_per_user => new_user_per_user,
      #:user_atteration => user_atteration
    }
    return list
  end

end
