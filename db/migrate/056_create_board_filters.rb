class CreateBoardFilters < ActiveRecord::Migration
  def self.up
    create_table "board_filters" do |t|
      t.column "filter",      :string, :default => ""
      t.column "user_id",     :integer, :null => false
    end
    add_index "board_filters", ["user_id", "filter"], :unique => true
  end
  
  def self.down
    drop_table "board_filters"
  end
end
