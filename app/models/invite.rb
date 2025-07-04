
class Invite < ActiveRecord::Base

  # --------------------------
  # Assosiations
  # --------------------------
  
  belongs_to :board
  belongs_to :inviter_user, :class_name => "User", :foreign_key => "inviter_user_id"
  belongs_to :accepted_user, :class_name => "User", :foreign_key => "accepted_user_id"
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by_id"
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by_id"
  
  # --------------------------
  # Validators
  # --------------------------
  validates_presence_of :board
  validates_presence_of :accepted_user
  validates_presence_of :updated_by
  validates_presence_of :status

  cattr_accessor :current_invite
  # --------------------------
  # Public Methods
  # --------------------------
  
  def self.find_pending *dates
    cond = "invites.status=2 and boards.status=1"
    unless dates.empty?
      dates.each_with_index { |date, i| cond << " #{i==0 ? "and (" : "or " }date(invites.created_on) = '#{date.strftime("%Y-%m-%d")}'" }
      cond << ")"
    end
    find(:all, :conditions => cond, :include => [:accepted_user, :inviter_user, :board])
  end
  
  def self.send_reminders *dates
    find_pending(*dates).each do |invite|
      begin
        Invite.reminder_mail(invite,User.new(:first_name => "The Stixy Team"))
        invite.update_attribute(:updated_on, Time.now)
        message = "Reminder sent on #{invite.created_on.strftime("%B %d, %Y %I:%M %p")} to #{invite.accepted_user.login} (#{invite.accepted_user.id}), for board #{invite.board.id}, with token #{invite.reference_token}"
       rescue => msg
        message = "ERROR #{Time.now.strftime("%B %d, %Y %I:%M %p")}: Couldn't send invitation for Accepted User ID: #{invite.accepted_user_id}. Message: #{msg}"
      end
      yield message
      logger.info message
    end
  end
  
  # gets human readable status of this record ( disabled or active)
  def status_name
    Status::STATUS_NAMES[self.status]
  end
  
  # returns true if this record is active
  def active?
    self.status == Status::ACTIVE
  end
  
  def activate
    self.status = Status::ACTIVE
    self.save
  end
  
  # Trigger sharing of the board to the accepted user when all coditions are met
  def join_board
    if accepted_user != nil
      bu = accepted_user.boardusers.find(:first, :conditions => ["board_id = ?", board.id])
      bu ||= accepted_user.boardusers.create(:board => board, :created_by => accepted_user)
      bu.update_attributes(:status => Status::ACTIVE, :updated_by => accepted_user)
      accepted_user.add_contact(inviter_user)
    end
    return true
  end 
  
  def self.reminder_mail invite=nil, sender=nil
    ActiveRecord::Base.silence { Notifier::deliver_invite(invite, invite.inviter_user, (sender||invite.inviter_user)) }
  end
  
  # --------------------------
  # Protected Methods
  # --------------------------
  protected
  
    
  # FIX for Rails 2.1 that doesn't allow mysql db taxt/blob columns to not allow null and have empty string as default
  # http://pennysmalls.com/2008/06/03/rails-210-breakage/ bullet 4
  def before_save
    self.invitation_text = "" if self.invitation_text.nil?
  end
  
  def before_create
    self.inviter_user = updated_by
    self.created_by = updated_by
    self.status = Status::PENDING
  end
  
  def after_create
    self.reference_token = User.sha1_no_salt(id.to_s)
    self.save
  end
  
  private
  
end
