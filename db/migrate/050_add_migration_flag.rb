class AddMigrationFlag < ActiveRecord::Migration
  def self.up
     add_column :library_photos, :migrated_date, :datetime
     add_column :library_documents, :migrated_date, :datetime
     add_column :user_images, :migrated_date, :datetime
  end
  
  def self.down
      remove_column :library_photos, :migrated_date
      remove_column :library_documents, :migrated_date
      remove_column :user_images, :migrated_date
  end
end
