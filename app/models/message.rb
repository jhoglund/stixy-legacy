class Message < ActiveRecord::Base
	belongs_to 	:messageable, :polymorphic => true
	belongs_to :sender, :class_name => 'User', :foreign_key => :sender_id
  has_and_belongs_to_many :recipients, 
													:join_table => 'switchboards', 
													:foreign_key => 'message_id',
													:class_name => 'User',
													:association_foreign_key => 'receiver_id'

end
