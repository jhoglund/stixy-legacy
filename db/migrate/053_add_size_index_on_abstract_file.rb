class AddSizeIndexOnAbstractFile < ActiveRecord::Migration
  def self.up
    add_index :abstract_files, :size
  end
  
  def self.down
    remove_index :abstract_files, :size
  end
end
