class ChangeGuest < ActiveRecord::Migration
  def self.up
    User.find_by_login("anonymous").update_attributes(:first_name => "", :email => "guest@stixy.com")
  end            
                 
  def self.down  
    User.find_by_login("anonymous")..update_attributes(:first_name => "Public", :email => "guesst@stixy.com")
  end
end
