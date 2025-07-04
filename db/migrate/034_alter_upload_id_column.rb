class AlterUploadIdColumn < ActiveRecord::Migration
  def self.up
    change_column "library_photos", "upload_id", :string, :limit => 255
    change_column "library_documents", "upload_id", :string, :limit => 255
  end
  
  def self.down
    change_column "library_photos", "upload_id", :string, :limit => 32
    change_column "library_documents", "upload_id", :string, :limit => 32
  end
end
