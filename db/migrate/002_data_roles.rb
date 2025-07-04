class DataRoles < ActiveRecord::Migration
  def self.up
    Role.create(:name => "Anonymous Role", :is_visible => 0, :status => 1) 
    Role.create(:name => "Administrator Role", :status => 1) 
    Role.create(:name => "User Role", :status => 1)
	end
end