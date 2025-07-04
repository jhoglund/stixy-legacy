class AlterPhotoPadding < ActiveRecord::Migration
  #def self.up
  #  WidgetPhoto.find(:all).each do |photo| 
  #    photo.styles.each do |style| 
  #      if style.attribute == "padding" 
  #        photo.styles.create(:attribute => "margin", :value => style.value, :name => "image-margin")
  #        style.destroy
  #      end
  #    end
  #  end
  #end
  #
  #def self.down
  #  WidgetPhoto.find(:all).each do |photo| 
  #    photo.styles.each do |style| 
  #      if style.attribute == "margin" and style.name == "image-margin"
  #        photo.styles.create(:attribute => "padding", :value => style.value)
  #        style.destroy
  #      end
  #    end
  #  end
  #end
end
