class DocumentFileResource < ActiveResource::Base
   self.site = "http://#{UPLOAD_SERVER}" 
   self.element_name = "document"
   self.prefix='/widgets/'   
end