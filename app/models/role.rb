class Role < ActiveRecord::Base

  # --------------------------
  # Assosiations
  # --------------------------
  has_and_belongs_to_many :users

  # --------------------------
  # Validators
  # --------------------------  
  validates_uniqueness_of :name
  validates_length_of :name, :within => 3..30
  # Errors.add_to_base("Foo") ---  how to add custom validation error
  
  # --------------------------
  # Static vars, enums and getters/setters
  # --------------------------
  
  # role ids enum
  ANON, ADMIN, USER, CALENDAR_BETA_TESTER, CALENDAR_PENDING = 1, 2, 3, 4, 5
  
  # Yes, No enum
  No, Yes = 0, 1
  
  # mapping arrays for enums
  IS_VISIBLE_NAMES = %w{No Yes}
  IS_LOCKED_NAMES = %w{No Yes}

  # --------------------------
  # Public Methods
  # --------------------------
  
  
  # gets human readable status od this record ( disabled or active)
  def status_name
    Status::STATUS_NAMES[self.status]
  end
  
  # returns true if this record is active
  def active?
    self.status == Status::ACTIVE
  end
  
  # returns Yes or No if role is locked
  # locking prevents roles from being edited
  def is_locked_str
    Role::IS_LOCKED_NAMES[self.is_locked]
  end
  
  # returns true or false if role is locked
  def is_locked?
    self.is_locked == Role::Yes
  end
  
  # returns Yes or No if role is visible
  # visibilty of the role guides the visibility of user in that role
  # example is anonymous user who is invisible in the app but pretty important
  def is_visible_str
    Role::IS_VISIBLE_NAMES[self.is_visible]
  end
  
   # returns true or false if role is visible
  def is_visible?
    self.is_visible == Role::Yes
  end
  
  # --------------------------
  # Protected Methods
  # --------------------------
  protected
  
  # framework callback
  def before_create
    self.name = self.name.downcase unless self.name == nil
    #self.created_by_id = User.current.id unless User.current.nil?
  end
  
  # framework callback
  def before_update 
    self.name = self.name.downcase unless self.name == nil
    #self.updated_by_id = User.current.id unless User.current.nil?
  end
  
end
