class DataBoards < ActiveRecord::Migration
  def self.up
    create_table "boardusers" do |t|
      t.column "board_id",      :integer, :null => false
      t.column "user_id",       :integer, :null => false
      t.column "status",        :integer, :limit => 4, :default => 1 
      t.column "created_on",    :datetime
      t.column "updated_on",    :datetime
      t.column "created_by_id",    :integer, :limit => 4, :default => 1 
      t.column "updated_by_id",    :integer, :limit => 4, :default => 1 
    end
    add_index "boardusers", ["user_id", "board_id"], :name => "boards_users_user_id_index", :unique => true
  
    [ { :board_data => { :title => "",                           :description => ""                                           },                                                                                                  :users => ["jonas@swatdesign.com"], :keywords => ["ski", "tahoe"] },
      { :board_data => { :title => "",                           :description => "Board with no title"                        },                                                                                                  :users => ["jonas@swatdesign.com"] },
      { :board_data => { :title => "Board with no description",  :description => ""                                           },                                                                                                  :users => ["jonas@swatdesign.com"] },
      { :board_data => { :title => "Yet another board",          :description => "This is the another board"                  },                                                                                                  :users => ["jonas@swatdesign.com", "adam_block@swatdesign.com"] },
      { :board_data => { :title => "Board with no description, but whith a long title that will be truncated",             :description => "This is the first board I created. The description is very long and should break" },  :users => ["jonas@swatdesign.com", "adam_block@swatdesign.com"], :keywords => ["golf", "karlshamn", "hcp", "tornament"]  },
      { :board_data => { :title => "",                           :description => ""                                           },                                                                                                  :users => ["jonas@swatdesign.com", "adam_block@swatdesign.com"] },
      { :board_data => { :title => "",                           :description => "Board with no title"                        },                                                                                                  :users => ["maria_distner@swatdesign.com", "jonas@swatdesign.com", "adam_block@swatdesign.com"] },
      { :board_data => { :title => "Board with no description",  :description => ""                                           },                                                                                                  :users => ["jonas@swatdesign.com", "adam_block@swatdesign.com", "maria_distner@swatdesign.com"] },
      { :board_data => { :title => "Yet another board",          :description => "This is the another board"                  },                                                                                                  :users => ["adam_block@swatdesign.com", "jonas@swatdesign.com", "maria_distner@swatdesign.com"] },
      { :board_data => { :title => "Board with content",         :description => "This is the first board I created. The description is very long and should break" },                                                            :users => ["jonas@swatdesign.com", "adam_block@swatdesign.com", "maria_distner@swatdesign.com"] },
      { :board_data => { :title => "",                           :description => ""                                           },                                                                                                  :users => ["jonas@swatdesign.com", "adam_block@swatdesign.com", "maria_distner@swatdesign.com", "agneta_distner@swatdesign.com"] },
      { :board_data => { :title => "",                           :description => "Board with no title"                        },                                                                                                  :users => ["jonas@swatdesign.com", "adam_block@swatdesign.com", "maria_distner@swatdesign.com", "agneta_distner@swatdesign.com"] },
      { :board_data => { :title => "Board with no description, but whith a long title that will be truncated",  :description => ""},                                                                                              :users => ["jonas@swatdesign.com", "adam_block@swatdesign.com", "maria_distner@swatdesign.com", "agneta_distner@swatdesign.com", "peter_ekman@swatdesign.com"] }
    ].each do |data|
      b = Board.new(data[:board_data].merge({:created_by => User.find_by_login(data[:users].first), :updated_by => User.find_by_login(data[:users].last)}))
      b.save
      data[:users].each do |u|
        b.boardusers.create!(:user => User.find_by_login(u))
      end
      if data[:keywords]
        data[:keywords].each do |k|
          tag = Keyword.find_by_tag(k) || Keyword.create(:tag => k, :created_by => User.find_by_login(data[:users].last), :updated_by => User.find_by_login(data[:users].first))
          b.keywords << tag
        end
      end
      b.save
    end
  end
  
  def self.down  
    drop_table "boardusers"
  end
end