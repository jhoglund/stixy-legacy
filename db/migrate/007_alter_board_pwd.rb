class AlterBoardPwd < ActiveRecord::Migration
  def self.up
    change_column "boards", "pwd", :string, :limit => 60
  end
  
  def self.down
    change_column "boards", "pwd", :integer, :limit => 60
  end
end
