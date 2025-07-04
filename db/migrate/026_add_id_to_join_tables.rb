class AddIdToJoinTables < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `library_documents_widget_instances` ADD `id` int NOT NULL auto_increment PRIMARY KEY;"
    execute "ALTER TABLE `library_photos_widget_instances` ADD `id` int NOT NULL auto_increment PRIMARY KEY;"
  end
  
  def self.down
    remove_column(:library_documents_widget_instances, :id)
    remove_column(:library_photos_widget_instances, :id)
  end
end
