class EditUsersAddReceiveNewsletter < ActiveRecord::Migration
  def self.up
		add_column :users, :receive_newsletter, :boolean, :default => true
  end

  def self.down
		remove_column :users, :receive_newsletter
  end
end
