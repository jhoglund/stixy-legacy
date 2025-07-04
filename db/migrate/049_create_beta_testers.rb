class CreateBetaTesters < ActiveRecord::Migration
  def self.up
    create_table :beta_testers do |t|
      t.column "user_id", :integer, :default => 1, :null => false
      t.column "comment", :text
      t.column "created_on", :datetime, :null => false
      t.column "updated_on", :datetime, :null => false
      t.column "created_by_id", :integer, :default => 0, :null => false
      t.column "updated_by_id", :integer, :default => 0, :null => false
      t.column "notify_only", :integer, :default => 0, :null => false
      t.column "status", :integer, :limit => 4, :default => 1, :null => false
    end
  end

  def self.down
    drop_table :beta_testers
  end
end
