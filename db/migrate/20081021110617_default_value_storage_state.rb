class DefaultValueStorageState < ActiveRecord::Migration
  def self.up
    change_column(:abstract_files, :storage_state, :integer, :null => true, :default => nil, :limit => 4)
  end

  def self.down
    change_column(:abstract_files, :storage_state, :integer, :null => false, :default => "0", :limit => 4)
  end
end
