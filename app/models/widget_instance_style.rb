class WidgetInstanceStyle < ActiveRecord::Base
  belongs_to :widget_instance
  
  # Alias for template compatibility - templates expect 'attr' but database uses 'attribute'
  def attr
    attribute
  end
  
  def attr=(value)
    self.attribute = value
  end
  
  #def attribute value
  #  write_attribute("attr", value)
  #end
end
