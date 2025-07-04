class AddS3FlagOnAbstractFile < ActiveRecord::Migration
  def self.up
    add_column :abstract_files, :storage_state, :integer, :limit => 4, :default => 0, :null => false
  end
  
  def self.down
    remove_column :abstract_files, :storage_state
  end
end
