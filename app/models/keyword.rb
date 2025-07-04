class Keyword < ActiveRecord::Base
 
  # --------------------------
  # Assosiations
  # --------------------------
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by_id" # Creator mapping
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by_id" # Creator mapping
  has_and_belongs_to_many :boards
  
  # --------------------------
  # Validators
  # --------------------------  
 
  validates_uniqueness_of :tag
  validates_length_of :tag, :within => 1..30

  # --------------------------
  # Protected Methods
  # --------------------------
  protected

  # framework callback
  def before_create
    self.tag = self.tag.downcase unless self.tag == nil
    #self.created_by = User.current unless User.current.nil?
  end
  
  # framework callback
  def before_update 
    self.tag = self.tag.downcase unless self.tag == nil
    #self.updated_by = User.current unless User.current.nil?
  end

end
