class Member < ActiveRecord::Base
	belongs_to  :membershipable, :polymorphic => true
	belongs_to  :user
	belongs_to  :calendar_entrie
	belongs_to  :calendar_todo
	has_many    :logs, :as => :loggable
	has_one 	  :notification, :as => :noteable #, :dependent => :destroy
  
  def self.deactivate!
    self.find(:all, :conditions => "status = #{Status::ACTIVE}").each do |m|
      # This is not the way to do it from a MVC point of view, having one model calling another. Yet, it's needed in the specific case.
		  Notification.update_all("status = #{Status::CANCELED}", "noteable_id = #{m.id} AND noteable_type = 'Member'")
		end
		self.update_all("status = #{Status::CANCELED}")
  end
	
  
	def send_notification(note=self.notification)
	  return_this = true
	  find_members.each do |member|
	    begin
	      return_this = false unless member.membershipable.send_notification(note, member.user)
	    rescue
	      return_this = false
	      next
      end
    end
    return return_this
  end
  
  def find_members
    if(self.user_id==0)
      return Member.find(:all, :conditions => ["user_id != 0 AND membershipable_type = ? AND membershipable_id = ?", self.membershipable_type, self.membershipable_id])
    else
      return [self]
    end
  end
  
end
