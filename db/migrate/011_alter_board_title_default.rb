class AlterBoardTitleDefault < ActiveRecord::Migration
  def self.up
    change_column "boards", "title", :string, :default => "", :null => false
    change_column "boards", "description", :text, :default => "", :null => false
  end
  
  def self.down
    change_column "boards", "title", :string, :default => "", :null => false
    change_column "boards", "description", :text, :default => "", :null => false
  end
end
