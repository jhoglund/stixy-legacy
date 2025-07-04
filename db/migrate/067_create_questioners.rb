class CreateQuestioners < ActiveRecord::Migration
  def self.up
    create_table :questioners, :options => "TYPE=MyISAM" do |t|
      t.column :label,      :string,    :default => '', :null => false,  :limit => 20
      t.column :name,       :string,    :default => '', :null => false,  :limit => 20
      t.column :value,      :integer,   :default => 0
      t.column :comment,    :text,      :default => ''
      t.column :user_login, :string,    :default => ''
      t.column :group_id,   :string,    :null => false, :limit => 32
      t.column :created_at, :datetime,  :null => false
      t.column :updated_at, :datetime,  :null => false
    end
  end

  def self.down
    drop_table :questioners
  end
end
