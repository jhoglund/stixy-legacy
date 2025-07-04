class AddSession < ActiveRecord::Migration
  def self.up
    create_table "sessions", :options => "TYPE=MyISAM" do |t|
      t.column "sessid", :string, :limit => 32
      t.column "data", :text
      t.column "updated_on", :datetime
    end
    add_index "sessions", ["sessid"], :name => "session_sessid_index"
  end
  
  def self.down
    drop_table "sessions"
  end
end
