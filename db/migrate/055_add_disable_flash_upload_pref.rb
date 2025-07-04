class AddDisableFlashUploadPref < ActiveRecord::Migration
  def self.up
    add_column "users", "pref_disable_flash_upload", :integer, :limit => 4, :default => 0
  end
  
  def self.down
    remove_column "users", "pref_disable_flash_upload"
  end
end
