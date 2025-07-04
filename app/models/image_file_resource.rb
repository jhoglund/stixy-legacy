class ImageFileResource < ActiveResource::Base
   self.site = "http://#{UPLOAD_SERVER}" 
   self.element_name = "photo"
   self.prefix='/widgets/'   
end