class AlertBoardListUiPrefDefault < ActiveRecord::Migration
  def self.up
    change_column "users", "pref_ui_board_list", :integer, :limit => 4, :default => 1
  end
  
  def self.down
    change_column "users", "pref_ui_board_list", :integer, :limit => 4, :default => 0
  end
end
