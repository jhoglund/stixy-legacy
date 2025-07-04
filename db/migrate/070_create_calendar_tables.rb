class CreateCalendarTables < ActiveRecord::Migration
  def self.up
    create_table :abstract_calendars do |t|
      t.column :subject, :string
      t.column :note, :text
			t.column :location, :string
    	t.column :status, :integer
      t.column :type, :string,  :limit => 20, :default => '', :null => false
  	end
    add_index :abstract_calendars, :status
    add_index :abstract_calendars, :type
    
    create_table :activities do |t|
      t.column :start, :datetime
      t.column :stop, :datetime
      t.column :activatable_id, :integer
			t.column :activatable_type, :string
    	t.column :unit, :integer, :default => 0
  		t.column :frequency, :integer, :default => 1
  		t.column :recurring_status, :integer, :default => 0
  		t.column :status, :integer, :default => 1
  	end
    add_index :activities, :activatable_type
    add_index :activities, :activatable_id
    add_index :activities, :start
    add_index :activities, :stop
    add_index :activities, :status
    add_index :activities, :recurring_status
    
    create_table :members do |t|
			t.column :user_id, :integer
			t.column :membershipable_id, :integer
			t.column :membershipable_type, :string
    end
    add_index :members, :membershipable_type
    add_index :members, :membershipable_id
    add_index :members, :user_id
    
    create_table :groups do |t|
			t.column :name, :string
			t.column :groupable_id, :integer
			t.column :groupable_type, :string
    end
    add_index :groups, :groupable_type
    add_index :groups, :groupable_id
    
    create_table :logs do |t|
			t.column :user_id, :integer
			t.column :status, :integer
			t.column :created_at, :datetime
			t.column :loggable_id, :integer
			t.column :loggable_type, :string
    end
    
    create_table :priorities do |t|
      t.column :level, :integer
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
      t.column :created_by, :integer
      t.column :updated_by, :integer
      t.column :priorable_id, :integer
			t.column :priorable_type, :string
    end
    add_index :priorities, :priorable_type
    add_index :priorities, :priorable_id
    add_index :priorities, :level
    
    create_table :notifications do |t|
			t.column :time, :datetime
			t.column :status, :integer
			t.column :noteable_id, :integer
			t.column :noteable_type, :string
    end
    add_index :notifications, :noteable_type
    add_index :notifications, :noteable_id
    add_index :notifications, :time
    add_index :notifications, :status
    
    create_table :widget_members do |t|
			t.column :widget_instance_id, :integer
			t.column :widget_membership_id, :integer
			t.column :widget_membership_type, :string
    end
    add_index :widget_members, :widget_instance_id
    add_index :widget_members, :widget_membership_id
    add_index :widget_members, :widget_membership_type
    
    add_column :users, :pref_time, :string, :limit => 10
	end

  def self.down
		drop_table :abstract_calendars
# 	drop_table :activities
#  drop_table :members
#  drop_table :groups
#  drop_table :logs
#	drop_table :priorities
#	drop_table :notifications
#  drop_table :widget_members
    
#		remove_column :users, :pref_time
  end
end
