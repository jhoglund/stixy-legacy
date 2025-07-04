class UserAdDisplay < ActiveRecord::Migration
  def self.up
    add_column :users, :display_ad, :boolean, :default => true
  end

  def self.down
    remove_column :users, :display_ad
  end
end
