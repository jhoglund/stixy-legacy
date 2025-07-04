class AlterPhotosLongblob < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE library_photos MODIFY file long"
  end
  
  def self.down
    change_column "library_photos", "file", :binary
  end
end
