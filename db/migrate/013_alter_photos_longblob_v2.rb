class AlterPhotosLongblobV2 < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE library_photos MODIFY file longblob"
  end
  
  def self.down
    execute "ALTER TABLE library_photos MODIFY file long"
  end
end
