class AddUserUiPref < ActiveRecord::Migration
  def self.up
    add_column "users", "pref_ui_board_options", :integer, :limit => 4, :default => 1
    add_column "users", "pref_ui_widget_tray", :integer, :limit => 4, :default => 1
  end
  
  def self.down
    remove_column "users", "pref_ui_board_options"
    remove_column "users", "pref_ui_widget_tray"
  end
end
