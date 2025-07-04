class AbstractCalendar < ActiveRecord::Base
  acts_as_taggable
	has_one 	:activity, :as => :activatable, :dependent => :destroy
	has_one 	:notification, :as => :noteable, :dependent => :destroy
	has_many 	:members, :as => :membershipable, :conditions => "members.status = #{Status::ACTIVE}"
	has_many 	:groups, :as => :groupable
	has_many 	:logs, :as => :loggable

  attr_accessor :current_user, :note_status
  attr_writer :notification_unit, :notification_state, :notification_members
    
  def send_notification(note=self.notification, user=nil)
    if user
      ActiveRecord::Base.silence do
        Reminder.deliver_reminder_mail(self, user, note, read_attribute(:type)) rescue return false
      end
    else
      members.each do |member|
        member.send_notification(note) rescue return false
      end
    end
    return true
  end
  
  def notify?
    !self.notification.nil? and self.notification.pending?
  end
  alias :notification_state :notify?
  
  def notification_value
    self.notification.value rescue 1
  end
  
  def notification_unit
    self.notification.unit rescue Notification::HOUR
  end 
  
  def notification_value= value
    begin
      @notification_value = Integer(value)
    rescue
    end
  end 
  
  def add_user= user
		self.members << Member.new(:user_id => user.id)
	end
	  
	def users= args
		self.members.destroy_all
	  args.each do |u|
			self.members << Member.new(:user_id => u.id)
		end
	end
  
  def calendar_text
		return subject unless subject.nil? or subject.empty?
    return "Untitled"
	end
	alias :text :calendar_text
    
  def set_notification
    if defined? @notification_state
      note = Notification.new(:value => @notification_value.to_i, :unit => @notification_unit.to_i)
      note.status = (@notification_state == "1") ? Status::PENDING : Status::DISABLED
      if note.status == Status::PENDING
        if self.activity and note.value > 0
          clear_notifications()
          note.offset_time(activity.start.dup)
          if @notification_members
            @notification_members.each do |member_id|
              member = self.members.find_by_user_id(member_id)
              new_note = note.dup
              new_note.id = nil
              member.notification = new_note
              member.notification.save
            end
          else
            self.notification = note
            self.notification.save
          end
        end
      else
        disable_notifications()
      end
      note
    end
  end
    
  def clear_notifications
    self.members.each do |member|
      member.notification.remove if member.notification(true)
    end
    self.notification.remove if self.notification(true)
  end

  def disable_notifications
    self.members.each do |member|
      member.notification.disable if member.notification(true)
    end
    self.notification.disable if self.notification(true)
  end
 	
	def remove
	  self.status = Status::DISABLED
	  self.activity.update_attribute(:status, Status::DISABLED) unless self.activity.nil?
	  self.notification.update_attribute(:status, Status::DISABLED) unless self.notification.nil?
	  self.members.update_all("status = #{Status::DISABLED}") unless self.members.nil?
  end
  
  def remove!
	  self.remove
	  self.save!
  end
	
  def self.find_for_user entry_id, user_id
    Member.find(:first, :conditions => ["membershipable_id = ? and membershipable_type = 'AbstractCalendar' and user_id = ?", entry_id, user_id]).membershipable
  rescue
    raise ActiveRecord::RecordNotFound.new("The calendar entry was not found")
  end

  def before_create
    self.status = Status::ACTIVE unless self.status
    self.logs << Log.create(:user_id => current_user.id, :status => 1) if current_user
  end
  
  def before_update
    self.logs << Log.create(:user_id => current_user.id, :status => 2) if current_user
  end

  before_save do |record|
    record.note = "" if record.note_status == "0"
  end

  after_save do |record|
    record.activity.save unless record.activity.nil?
    record.members.each do |m|
      m.save
    end
    record.set_notification
  end
   
  protected
    
  def parse_time value=Time.now
    return value if value.is_a? Time
    year=value[:year]; month=value[:month]; day=value[:day]; hour=value[:hour]; minute=value[:minute]; suffix=(value[:suffix]||"")
    hour =  (hour.to_i + 12) if (suffix.downcase=="pm" and hour.to_i < 12)
    return Time.local(year, month, day, hour, minute) rescue nil
  end
  
  private
  
  # ActionMailer disabled for Ruby 2.7 compatibility
  if defined?(ActionMailer::Base)
    class Reminder < ActionMailer::Base
      include ActionView::Helpers::TextHelper
    	include ActionView::Helpers::SanitizeHelper

      def reminder_mail(calendar_entry, user, note, reminder_type)
        begin
          subj = calendar_entry.calendar_text.empty? ? "" : ": #{truncate(strip_tags(calendar_entry.calendar_text).gsub("&nbsp;", " ").gsub(/\s+/," "), 50)}"
          address = (RAILS_ENV == "development") ? "hoglundj@gmail.com" : user.email
          recipients address
          #priority Priority::HIGH
        if reminder_type == "CalendarEntry"
          from  "Calendar Reminder <reminder@stixy.com>"
          subject "[Stixy] Calendar Reminder#{ subj }"
          body render_message("calendar_entry.text.plain.rhtml", :entry => calendar_entry, :notification => note, :user => user)
        else
          from  "Calendar To-Do Reminder <reminder@stixy.com>"
          subject "[Stixy] Calendar To-Do Reminder#{ subj }"
          body render_message("todo_entry.text.plain.rhtml", :entry => calendar_entry, :notification => note, :user => user)
        end
        rescue => msg
          p msg
        end
      end
    end
  else
    # Stub class when ActionMailer is disabled
    class Reminder
      def self.deliver_reminder_mail(*args)
        # No-op when ActionMailer is disabled
        true
      end
    end
  end
  
end
