class AddBoardListUiPref < ActiveRecord::Migration
  def self.up
    add_column "users", "pref_ui_board_list", :integer, :limit => 4, :default => 0
  end
  
  def self.down
    remove_column "users", "pref_ui_board_list"
  end
end
