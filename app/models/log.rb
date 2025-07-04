class Log < ActiveRecord::Base
	belongs_to :loggable, :polymorphic => true



#	def before_create
#		self.date = Time.now
#	end
end
