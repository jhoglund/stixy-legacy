class BetaTester < ActiveRecord::Base
  belongs_to :user
  has_one :created_by, :class_name => "User"
  has_one :updated_by, :class_name => "User"
  validates_associated :user
  
  attr_accessor :new_beta_tester
  
  class << self
    def notify_only
      find(:all, :order => "created_by_id, id", :conditions => "notify_only = 1")
    end                     
                          
    def new_invites         
      find(:all, :order => "created_by_id, id", :conditions => "notify_only = 0").select do |beta_user|
        beta_user.user.pending_invitations.empty? and beta_user.user.status == Status::PENDING
      end
    end                     
                          
    def reminder_invites    
      find(:all, :order => "beta_testers.created_by_id, beta_testers.id", :conditions => "beta_testers.notify_only = 0").select do |beta_user|
        !beta_user.user.pending_invitations.empty?
      end
    end
    
    def find_by_user_login login=nil
      find(:first, :conditions => ["user_id = ?", User.find_by_login(login).id]) rescue nil
    end
    
    def accepted_invites
      find(:all, :order => "created_by_id, id", :conditions => "notify_only = 0").select do |beta_user|
        !beta_user.user.accepted_invitations.empty?
      end
    end
    
    def all    
      find(:all, :order => "created_by_id, id")
    end
  end
end
