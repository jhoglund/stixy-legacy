class AddUserUiPrefWopt < ActiveRecord::Migration
  def self.up
    add_column "users", "pref_ui_auto_show_wopt", :integer, :limit => 4, :default => 1
  end
  
  def self.down
    remove_column "users", "pref_ui_auto_show_wopt"
  end
end
