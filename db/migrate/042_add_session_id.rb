class AddSessionId < ActiveRecord::Migration
  def self.up
    add_column "library_photos", "session_id", :string, :limit => 32
    add_column "library_documents", "session_id", :string, :limit => 32
  end
  
  def self.down
    remove_column "library_photos", "session_id", :string, :limit => 32
    remove_column "library_documents", "session_id", :string, :limit => 32
  end
end
