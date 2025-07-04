require 'mini_magick'

class ThumbnailFile < AbstractFile
    has_attachment :storage => :s3, 
        :s3_access => :public_read,
        :path_prefix => 'content/thumbs'
   
   # Fix so thumbnail relations are generated even though they are not specified by the has_attachment method
   belongs_to :parent, :class_name => "AbstractFile" 
   
   # Shared extensions to AttachmentFu
   include AttachmentFuExtensions
    
   def base_name name
     "content/thumbs/#{name}/#{filename}"
   end
   
   # Test if ANY of the conditions provided is different from what's stored in the db
   def has_changed?(conditions)
     conditions[:width] = 0 if conditions[:width].nil?
     conditions[:width] = 0 if conditions[:width].nil?
     conditions[:rotation] = 0 if conditions[:rotation].nil?
     conditions[:filter] = 0 if conditions[:filter].nil?
     conditions[:width] = conditions[:width].to_i > 0 ? conditions[:width] : self.width
     conditions[:height] = conditions[:height].to_i > 0 ? conditions[:height] : self.height
     if conditions[:width].to_i == self.width.to_i && conditions[:height].to_i == self.height.to_i && conditions[:filter].to_i == self.filter.to_i && conditions[:rotation].to_i == self.rotation.to_i
       return false
     else
       return true
     end
   end
  
   def public_uri
     "#{s3_url}?#{[width,height,rotation,filter].to_s}"
   end  
         
end