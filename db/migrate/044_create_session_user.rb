class CreateSessionUser < ActiveRecord::Migration
  def self.up
    create_table "sessions_users" do |t|
      t.column "session_id",  :integer, :null => false
      t.column "user_id",     :integer, :null => false
      t.column "signed_in",   :datetime
      t.column "signed_out",  :datetime
    end
    add_index "sessions_users", ["session_id", "user_id"], :name => "sessions_users_id_index", :unique => true
  end            
                
  def self.down  
    drop_table "sessions_users"
  end
end