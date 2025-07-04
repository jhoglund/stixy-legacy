class CreateSwitchboards < ActiveRecord::Migration
  def self.up
    create_table :switchboards, :id => false do |t|
			t.column :receiver_id, :integer
			t.column :message_id, :integer
    end
  end

  def self.down
    drop_table :switchboards
  end
end



