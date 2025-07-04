class Notification < ActiveRecord::Base

	belongs_to :noteable, :polymorphic => true
	has_many :logs, :as => :loggable

  UNITS = %w{ MINUTE HOUR DAY }
  MINUTE, HOUR, DAY = 0, 1, 2


  def self.deliver(time=Time.now)
    reminders = self.find_reminders(time).each do |n|
      begin
        if n.noteable.send_notification
          n.noteable.after_notification_delivered(n) rescue nil
          n.status = Status::FINISHED unless n.status == Status::PENDING_RECURRING
          n.save
        end
      rescue => m
        next
      end
    end
    reminders.size
  end
  
  def offset_time t=Time.now
    self.time = t
    self.time -=  case self.unit
                  when Notification::MINUTE then (60*self.value)
                  when Notification::HOUR   then (60*60*self.value)
                  when Notification::DAY    then (60*60*24*self.value)
    end
  end
  
  def remind_time
    self.time +=  case self.unit
                  when Notification::MINUTE then (60*self.value)
                  when Notification::HOUR   then (60*60*self.value)
                  when Notification::DAY    then (60*60*24*self.value)
    end
  end
  
  def deactivate!
		self.update_attribute("status = #{Status::CANCELED}")
  end
  
  def deactivate
		self.status = Status::CANCELED
  end
  	  
  def remove
     Notification.delete(id) if pending?
  end
  
  def disable
    update_attribute(:status, Status::DISABLED)
  end
  
  def disabled?
    status == Status::DISABLED
  end
  
  def finished?
    status == Status::FINISHED
  end
  
  def pending?
    status == Status::PENDING || status == Status::PENDING_RECURRING
  end
  
  private
  
  def self.find_reminders(time)
    return find(:all, :conditions => ["(notifications.status = ? or notifications.status = ?) and notifications.time <= ?", Status::PENDING, Status::PENDING_RECURRING, time.strftime("%Y-%m-%d %H:%M:%S")])
  end

end




