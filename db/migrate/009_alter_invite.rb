class AlterInvite < ActiveRecord::Migration
  def self.up
    add_column "invites", "created_on", :datetime, :null => false
    add_column "invites", "updated_on", :datetime, :null => false
    add_column "invites", "created_by_id", :integer, :default => 1, :null => false
    add_column "invites", "updated_by_id", :integer, :default => 1, :null => false
  end
  
  def self.down
    remove_column "invites", "created_on"
    remove_column "invites", "updated_on"
    remove_column "invites", "created_by_id"
    remove_column "invites", "updated_by_id"
  end
end
