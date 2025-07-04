require 'digest/sha1'
class User < ActiveRecord::Base
  has_one :beta_tester
  has_one :personal_image, :class_name => "AvatarFile"
  has_one :created_by, :class_name => "User"
  has_one :updated_by, :class_name => "User"
  has_many :assets, :class_name => "AbstractFile"  # All assets
  has_many :library_photos, :class_name => "ImageFile"  # Library photos
  has_many :library_documents, :class_name => "DocumentFile" # Library photos # Library documents
  has_many :pending_invitations, :class_name => "Invite", :foreign_key => "accepted_user_id", :conditions => "status = 2" # user invitations
  has_many :accepted_invitations, :class_name => "Invite", :foreign_key => "accepted_user_id", :conditions => "status = 1"  # user invitations
  has_many :invitations, :class_name => "Invite", :foreign_key => "accepted_user_id", :dependent => :destroy  # user invitations
  has_many :invited_by, :class_name => "User", :foreign_key => "created_by_id", :order => "first_name, last_name"   # all other users invited by user
  has_many :keywords  # Keywords created mapping
  has_and_belongs_to_many :roles, :conditions => "roles.status = 1", :order => "name" # roles that this user has
  has_and_belongs_to_many :boards, 
    :join_table => "boards_users",
    :conditions => "boards.status = 1", 
    :order => "boards.updated_on DESC"
  has_and_belongs_to_many :contacts, :class_name => "User", :join_table => "users_contacts", 
    :association_foreign_key => "contact_id", :conditions => "(users.status = 1 or users.status = 2)", :order => "first_name, last_name" # user contacts
  has_many :board_filters, :order => "id asc"
  has_many :user_tags
  has_many :tags, :through => :user_tags
  has_many :user_notifications, :dependent => :destroy
	has_many :memberships, :class_name => "Member", :foreign_key => "user_id"
  # Messages
	has_many :sent_messages, :class_name => 'Message', :foreign_key => :sender_id
	has_and_belongs_to_many :received_messages, :join_table => :switchboards, :foreign_key => :receiver_id, :class_name => 'Message'
	
  # Virtual attribute for the unencrypted password, etc
  attr_accessor :pwd, :terms_of_service, :password_required


  validates_presence_of       :pwd,                                                                     :if => :password_required?
  validates_confirmation_of   :pwd,                 :message => ErrorMessages::Password::MISSMATCH,     :if => :password_required?  
  validates_length_of         :pwd,                 :message => ErrorMessages::Password::TOO_SHORT,     :if => :password_required?, :minimum => 6  
  validates_length_of         :pwd,                 :message => ErrorMessages::Password::TOO_LONG,      :if => :password_required?, :maximum => 30  
  validates_presence_of       :login                                                                   
  validates_confirmation_of   :login,               :message => ErrorMessages::Login::MISSMATCH
  validates_email_veracity_of :login,               :message => ErrorMessages::Login::NOT_VALID,        :domain_check => false
# validates_email_veracity_of :login,               :message => ErrorMessages::Login::NONE_EXISTING,    :if => Proc.new{|u| ENV["RAILS_ENV"] != "test"}
#	validates_format_of         :login,               :message => ErrorMessages::Login::NOT_VALID,        :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validates_presence_of       :roles,               :message => ErrorMessages::Misc::BLANK_ROLE,        :on => :create
  validates_acceptance_of     :terms_of_service,    :message => ErrorMessages::Misc::TERMS_OF_SERVICE,  :if => Proc.new{|u| defined? u.terms_of_service }
  
  before_save :encrypt_password, :set_email 
    
  # --------------------------
  # Public Methods
  # --------------------------

  # Override the display ad flag set in the user db
  def display_ad?
    false
  end
  
  
  def assets_size
    assets.collect{|a| a.size }.sum
  end
  
  def assets_formated_size s="auto"
    bytes = assets_size
    if s.to_s == "auto"
      if bytes > 1073741823
        s,a = "gigabytes","GB"
      elsif bytes > 1048575 
        s,a = "megabytes","MB"
      else
        s,a = "kilobytes","kB"
      end
    end
    v = bytes / 1.send(s.to_s)
    total_size = HashWithIndifferentAccess.new(:value => (s.to_s=="kilobytes" ? v.to_i : (v*100).to_i.to_f/100),:abr => a)
		"#{total_size[:value]} #{total_size[:abr]}"
  end
  
  # # Fix for Rails 2.1 that will write NULL if no value is submited
  # 
  # def description
  #   read_attribute(:description) || ""
  # end
  
  def time_format
    @time_format ||= Stixy::TimeFormat.new(pref_time)
  end
  
  def time_format= values={}
    if date = values.delete(:date)
      values[:numeric_date] = date
      values[:long_date] = (date.to_i < 2) ? 0:1
    end
    time_format.set(values)
    write_attribute(:pref_time, time_format.to_s)
  end
  
  def adjusted_time(time=Time.now, daylight_saving=true)
    time = to_time(time)
    time + read_attribute(:time_offset) + (daylight_saving ? (read_attribute(:daylight_savings)*3600) : 0)
  end
  
  def reset_time(time=Time.now, daylight_saving=true)
    time = to_time(time)
    time - read_attribute(:time_offset) - (daylight_saving ? (read_attribute(:daylight_savings)*3600) : 0)
  end
  
  def last_login_date
    date = read_attribute(:last_login_date)
    (date < Time.parse("January 01, 2000")) ? nil : date
  end

  def self.get id
    User.find(id) rescue User.find(1)
  end
  
  def board_invitation board
    pending_invitations.select{ |i| i.board == board}.first
  end
  
  def is_invited_to_board? board
    pending_invitations.select{ |i| i.board == board}.first
  end
  
  def is_user_of_board? board
    boards.include? board
  end
    
  # Checks to see if it's a new user
  def first_login?
    return created_on == updated_on ? true : false
  end
  
  # helper 
  # Gets the display name if it exist or email address otherwise
  def display_name
    f_name = first_name unless first_name.empty?
    l_name = last_name unless last_name.empty?
    (f_name && l_name!=nil ? (f_name + " " + l_name) : (f_name ? f_name : (l_name ? l_name : self.login)))
  end
  
  # helper 
  # Gets the full name if it exist
  def full_name
    name = [self.first_name, self.last_name].compact
    return name.join(" ") unless name.empty?
  end
  
  # helper 
  # Gets the full first name if it exist, otherwise the display name
  def nick_name
    return first_name unless first_name.empty?
    return display_name
  end
  
  # helper 
  # Trims display names to Initial and full Last Name. I.E "J Hoglund"
  # Trims email to name without @ and domain name
  def short_name
    name = self.display_name
    unless name.include? "@"
      name_split = name.split
      return (name_split.size > 1 ? name_split.first.slice(0,1) + " " : "" ) + name_split.last 
    else
      return name.split('@').first
    end
  end
    
  def board_modified board
    # With HABTM relationship, we can't track visited_on times in the join table
    # This functionality would need to be implemented differently if needed
  end
  
  def board_visited board
    # With HABTM relationship, we can't track visited_on times in the join table  
    # This functionality would need to be implemented differently if needed
  end  
  
  def avatar_url
    unless self.personal_image.nil?
      self.personal_image.public_uri
    else 
      "/images/user_icons/icon_placeholder_user_"+ "#{((self.id ? self.id : rand(9))).to_s.last.to_i+1}" +".jpg"
    end
  end
  
  # With no salt to generate tokens
  def self.sha1_no_salt(pass)
    Digest::SHA1.hexdigest(pass)
  end
  
  
  
  # private_keys
  #   id:
  #   user_id:
  #   public_id:
  #   public_key: Digest::SHA1.hexdigest("#{user.salt}#{Time.new.to_f}")
    
    
  ## Private_key methods - Set and get
  #   
  def get_private_key
    if self.private_key.nil?
      self.private_key = Digest::SHA1.hexdigest("#{self.salt}#{Time.new.to_f}")
      self.save
    end
    return self.private_key
  end
  
  ## Get user id from private key
  #
  def self.get_id_from_private_key(key)
    user = User.find( :first,
                      :select => :id,
                      :conditions => ["private_key = ?", key.to_s])
    return (!user.nil? ? user.id : nil)
  end
  
  
  # User.find(:first, :select => :id, :conditions => ["private_key = ?", key])
  # --------------------------
  # User authentication
  # --------------------------
  
  def in_role? role_id
    return roles.select{ |element| element.id == role_id}.size == 1
  end
  
  def authorized?
    return true if in_role?(Role::ADMIN) || in_role?(Role::USER) 
    return false
  end
  
  # Add another user as a contact to this user
  #   and vice versa (another user gets this user as acontact too)
  #
  def add_contact another_user
    if not self.contacts.include?(another_user)
      self.contacts << another_user
      self.save
    end
    if not another_user.contacts.include?(self)
      another_user.contacts << self
      another_user.save
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
  
  # Returns visibility flag of user based on visibility of its role.
  # The method is used to determine if to display the user in various UI components such as shared board user lis
  # not visible generally means anonymous user which is internal housekkeping user for public boards
  #
  # the logic is such :
  #  - true if at least one role is visible
  #  - false otherwise
  def is_visible?
    self.roles.each do | role |
      return true if role.is_visible?
    end
    return false
  end

  # --------------------------
  # Act as Authenticated
  # --------------------------

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login_and_status(login,Status::ACTIVE) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 5.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  
  def deactivate!
		update_attribute(:status, Status::CANCELED)		
  end

  protected
		# Validate uniqueness of login exept users that are canceled
	 def validate
	   user_using_login = User.find_by_login(self.login, :conditions => ["status != ?", Status::CANCELED])
	   if user_using_login && user_using_login != self
	     errors.add :login, ErrorMessages::Login::USED
	     return false
	   end
	   true
	 end 
   
   def to_time(time=Time.now)
    return (time.class == Time) ? time : Time.local(time.year, time.month, time.day)
   end
    # before filter 
    
    # FIX for Rails 2.1 that doesn't allow mysql db taxt/blob columns to not allow null and have empty string as default
    # http://pennysmalls.com/2008/06/03/rails-210-breakage/ bullet 4
    def before_save
      self.description = "" if self.description.nil?
    end
    
    def before_create
      self.last_login_date = Time.at(0)
    end
    
    def set_email
      self.email = self.login
    end
    
    def encrypt_password
      return if pwd.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(pwd)
    end
    
    def password_required?
      crypted_password.blank? || !pwd.blank? || password_required
    end
    
    def login_required?
      !login_required.blank?
    end    
end
