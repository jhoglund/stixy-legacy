class Boarduser < ActiveRecord::Base
  belongs_to :board
  belongs_to :user
  belongs_to :created_by, :class_name => "User", :foreign_key => "created_by_id"
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by_id"
  
  def last_modified
    find(:first, :conditions => "order by updated_on")
  end
  
  protected
  
  def before_create
    self.visited_on = Time.now if self.visited_on.nil?
    self.created_on = Time.now if self.created_on.nil?
    self.updated_on = Time.now if self.updated_on.nil?
  end
end