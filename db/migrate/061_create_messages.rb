class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
			t.column :sender_id, :integer

			t.column :root_id, :integer
			t.column :parent_id, :integer
			t.column :lft, :integer
			t.column :rgt, :integer
			t.column :depth, :integer

			t.column :messageable_id, :integer
			t.column :messageable_type, :string
			t.column :created_at, :datetime
			t.column :updated_at,	:datetime
			t.column :text, :text
    end
  end

  def self.down
    drop_table :messages
  end
end
