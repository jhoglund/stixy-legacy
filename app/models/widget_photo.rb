class WidgetPhoto < WidgetInstance
  has_many  :styles, :class_name => "WidgetInstanceStyle", :foreign_key => "widget_instance_id", :dependent => :destroy
  has_many  :photos, :through => :library_photos_widget_instances, :dependent => :destroy
  has_many  :library_photos_widget_instances, :foreign_key => "widget_instance_id", :dependent => :destroy
  belongs_to :widget
  
  
  def initialize p=nil
    super(p)
    self.widget_id = 2
  end
  
  def self.get(board_id, status=Status::ACTIVE)
    find(:all, :conditions => "widget_name = 'WidgetPhoto' and board_id = #{board_id} and widget_instances.status = #{status}", :include => [:widget, :photos, :styles, :library_photos_widget_instances])
  end
  
  def instance_attributes *att	
    str = super(*att)
    return "#{str},width:#{photo.thumb(:t).width},height:#{photo.thumb(:t).height},rotation:#{photo.thumb(:t).rotation},filter:#{photo.thumb(:t).filter},id:#{photo.id}" rescue str
  end
  
  def file= param
    if(param[:photo_id]&&(param[:photo_id]!="0"))
      self.library_photos_widget_instances(true).each{|w| w.destroy }
      self.library_photos_widget_instances.create!(:photo => ImageFile.find(param[:photo_id]))
    end
  end
  alias :photo= :file=
  
  def photo
    photos.first
  end
  alias :file :photo
  
  def style= params=[]
    unless params.nil?
      params.each do |key,value|
        self.styles.find_or_create_by_name_and_attr(value[:name],key, :select => :value).update_attribute(:value,value[:value]||value)
      end
    end
  end
  
  def copy *args
    widget = clone
    styles.each do |style|
      widget.styles << style.clone
    end
    cloned_photo = photo.copy
    widget.save!
    widget.library_photos_widget_instances.create(:widget_instance_id => widget.id, :library_photo_id => cloned_photo.id)
    return widget
  end
  

end
