class RemoveFromInvite < ActiveRecord::Migration
  def self.up
    remove_column "invites", "nick_name"
    remove_column "invites", "first_name"
    remove_column "invites", "last_name" 
    remove_column "invites", "email"
  end
  
  def self.down
    add_column "invites", "nick_name", :string
    add_column "invites", "first_name", :string
    add_column "invites", "last_name", :string
    add_column "invites", "email", :string
  end
end
