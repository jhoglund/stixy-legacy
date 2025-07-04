class WidgetMember < ActiveRecord::Base
	belongs_to :widget_membership, :polymorphic => true

end
