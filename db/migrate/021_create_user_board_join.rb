class CreateUserBoardJoin < ActiveRecord::Migration
  #Removed and moved to the "005_data_boards.rb" because the Model has changed.
  #def self.up
  #  create_table "boardusers" do |t|
  #    t.column "board_id",      :integer, :null => false
  #    t.column "user_id",       :integer, :null => false
  #    t.column "status",        :integer, :limit => 4, :default => 1 
  #    t.column "created_on",    :datetime
  #    t.column "updated_on",    :datetime
  #    t.column "created_by_id",    :integer, :limit => 4, :default => 1 
  #    t.column "updated_by_id",    :integer, :limit => 4, :default => 1 
  #  end
  #  add_index "boardusers", ["user_id", "board_id"], :name => "boards_users_user_id_index", :unique => true
  #  Board.find(:all).each do |board|
  #    board.users.each do |user|
  #      createor = board.users[rand(board.users.size)]
  #      updator  = board.users[rand(board.users.size)]
  #      board.boardusers.create(
  #        :user => user,
  #        :created_by_id => createor.id,
  #        :updated_by_id => updator.id
  #      )
  #    end
  #  end
  #end            
                 
  #def self.down  
  #  drop_table "boardusers"
  #end
end
