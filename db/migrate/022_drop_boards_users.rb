class DropBoardsUsers < ActiveRecord::Migration
  def self.up
    drop_table "boards_users"    
  end            
                 
  def self.down  
    create_table "boards_users", :id => false, :options => "TYPE=MyISAM" do |t|
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "board_id", :integer, :default => 0, :null => false
    end

    add_index "boards_users", ["user_id", "board_id"], :name => "boards_users_user_id_index", :unique => true
    
    Board.find(:all).each do |board|
      board.users.each do |user|
        createor = board.users[rand(board.users.size)]
        updator  = board.users[rand(board.users.size)]
        board.boardusers.create(
          :user => user,
          :created_by_id => createor.id,
          :updated_by_id => updator.id
        )
      end
    end
  end
end
