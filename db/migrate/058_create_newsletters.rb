class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
			t.column :user_id, :integer
			t.column :created_at, :datetime
			t.column :updated_at, :datetime
			t.column :subject, :string
			t.column :body, :text
    end
  end

  def self.down
    drop_table :newsletters
  end
end
