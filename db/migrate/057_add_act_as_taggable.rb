class AddActAsTaggable < ActiveRecord::Migration
  def self.up
    create_table :taggings do |t|
      t.column :taggable_id, :integer
      t.column :tag_id, :integer
      t.column :taggable_type, :string
    end
    create_table :tags do |t|
      t.column :name, :string
    end
    create_table :user_tags do |t|
      t.column :tag_id, :integer
      t.column :user_id, :integer
      t.column :created_on, :datetime
    end
    
  end

  def self.down
    drop_table :taggings
    drop_table :tags
    drop_table :user_tags
  end
end

