class WidgetNote < WidgetInstance
  has_one   :widget_instance_text,  :dependent => :destroy, :foreign_key => "widget_instance_id"     
  has_many  :styles, :class_name => "WidgetInstanceStyle", :dependent => :destroy, :foreign_key => "widget_instance_id"
  belongs_to :widget
  
  
  def initialize p=nil
    super(p)
    self.widget_id = 1
  end
    
  def self.get(board_id, status=Status::ACTIVE)
    find(:all, :conditions => "widget_name = 'WidgetNote' and board_id = #{board_id} and widget_instances.status = #{status}", :include => [:widget, :widget_instance_text, :styles])
  end      
  
  def instance_attributes *att
    return super(*att)
  end
  
  def content
    (self.widget_instance_text || WidgetInstanceText.new).value
  end
  alias :text :content
  
  def content= text
    self.widget_instance_text ||=  WidgetInstanceText.new(:value => text[:value])
    self.widget_instance_text.update_attributes!(:value => text[:value])
  end
  alias :text= :content=

  def style= params=[]
    unless params.nil?
      params.each do |key,value|
        self.styles.find_or_create_by_name_and_attr(value[:name],key, :select => :value).update_attribute(:value,value[:value]||value)
      end
    end
  end
  
  def copy *args
    widget = clone
    widget.widget_instance_text = widget_instance_text.clone if widget_instance_text
    styles.each do |style|
      widget.styles << style.clone
    end
    widget.save!
    return widget
  end

end
