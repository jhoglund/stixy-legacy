class PhotoMarginTr < ActiveRecord::Migration
  def self.up
    WidgetInstanceStyle.find(:all, :conditions => "name = 'image-margin'").each do |image|
      image.update_attribute(:value, image.value.to_i)
    end
  end            
                
  def self.down  
    WidgetInstanceStyle.find(:all, :conditions => "name = 'image-margin'").each do |image|
      image.update_attribute(:value, "#{image.value}px")
    end
  end
end