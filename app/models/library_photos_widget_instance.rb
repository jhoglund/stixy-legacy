class LibraryPhotosWidgetInstance < ActiveRecord::Base
  belongs_to :widget_instance
  belongs_to :photo, :class_name => "ImageFile", :foreign_key => "library_photo_id"
end