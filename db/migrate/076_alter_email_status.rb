class AlterEmailStatus < ActiveRecord::Migration
  def self.up
    add_column :emails, :status, :integer, :limit => 4, :default => Status::PENDING
	end

  def self.down
		remove_column  :emails, :status
  end
end
