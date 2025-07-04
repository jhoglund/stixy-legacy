class EditUsersAlterTimePref < ActiveRecord::Migration
  def self.up
    change_column :users, :pref_time, :string, :limit => 32
  end

  def self.down
    change_column :users, :pref_time, :string, :limit => 10
  end
end
