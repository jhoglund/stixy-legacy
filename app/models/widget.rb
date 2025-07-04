class Widget < ActiveRecord::Base
  has_many :widget_instances
  belongs_to :widget_instance
end
