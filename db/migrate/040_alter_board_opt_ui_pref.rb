class AlterBoardOptUiPref < ActiveRecord::Migration
  def self.up
    @user = User.find(1)
    @user.pref_ui_board_options = 0
    @user.save_without_validation
  end
  
  def self.down
    @user = User.find(1)
    @user.pref_ui_board_options = 1
    @user.save_without_validation
  end
end
