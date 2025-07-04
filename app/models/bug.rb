class Bug < ActiveRecord::Base
  
  #validates_presence_of :first_name
  #validates_presence_of :last_name
  validates_presence_of :email
  validates_email_veracity_of :email,               :message => ErrorMessages::Login::NOT_VALID,        :domain_check => false
  validates_presence_of :description  
  
  def first_name= name=nil
    write_attribute(:first_name, name||"")
  end
  
  def last_name= name=nil
    write_attribute(:last_name, name||"")
  end
  
end
