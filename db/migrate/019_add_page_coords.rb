class AddPageCoords < ActiveRecord::Migration
  def self.up
    add_column "boards", "top", :integer, :default => 0
    add_column "boards", "left", :integer, :default => 0
  end
  
  def self.down
    remove_column "boards", "top"
    remove_column "boards", "left"
  end
end
