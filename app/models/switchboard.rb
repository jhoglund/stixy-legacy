class Switchboard < ActiveRecord::Base
	belongs_to :message
	belongs_to :sender, :class_name => "User", :foreign_key => "user_id"
	belongs_to :receiver, :class_name => "User", :foreign_key => "user_id"
end
