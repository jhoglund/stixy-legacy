class AddMemberStatus < ActiveRecord::Migration
  def self.up
    add_column :members, :status, :integer, :default => 1
    add_index :members, :status    
  end

  def self.down
    remove_column :members, :status
  end
end
