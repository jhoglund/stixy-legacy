class CreateBugs < ActiveRecord::Migration
  def self.up
    create_table :bugs do |t|
      t.column :user_id, :integer, :default => 0, :null => false
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :email, :string, :null => false
      t.column :user_agent, :string
      t.column :platform, :string
      t.column :browser, :string
      t.column :description, :text
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :bugs
  end
end
