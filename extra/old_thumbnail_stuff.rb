# OK to be removed by 1st of January 2009

 DISABLED_FINAL, DISABLED_PENDING, DISABLED_UPLOADED  = 0, 1, 2
  
     # Overrides AttachmentFu's attachment_path_id method.
     # The attachment ID used in the full path of a file
     def attachment_path_id
       path_name = ((respond_to?(:parent_id) && parent_id) || id).to_s
       old_s3_implementation? ? path_name : encode(path_name)
     end   

     # Images with storage_states as below, doesn't have the path name encrypted.
     def old_s3_implementation?
       self.storage_state == DISABLED_PENDING || self.storage_state == DISABLED_UPLOADED || self.storage_state == DISABLED_FINAL
     end

     # Used for copying old names to new. Not to be used in production. Remove when done!!

     # def test
     #      new_exist =  AWS::S3::S3Object.exists?(self.new_name, 'stixy')
     #      old_exist = AWS::S3::S3Object.exists?(self.old_name, 'stixy')
     #      if new_exist and old_exist
     #              update_attribute(:storage_state, 16)
     #      elsif new_exist
     #              update_attribute(:storage_state, 17)
     #      elsif old_exist
     #              update_attribute(:storage_state, 18)
     #      else
     #              update_attribute(:storage_state, 19)
     #      end
     # end

     def old_name
       base_name(parent_id)
     end
     def new_name
       base_name("backup/#{parent_id}")
     end
     def base_name name
       "content/thumbs/#{name}/#{filename}"
     end
     #def copy_to_new
     #  begin
     #    if !AWS::S3::S3Object.exists?(self.new_name, 'stixy') and AWS::S3::S3Object.exists?(self.old_name, 'stixy') and AWS::S3::S3Object.copy(self.old_name, self.new_name, 'stixy') 
     #      self.update_attribute(:storage_state, 9)
     #      f = AWS::S3::S3Object.acl(self.new_name, 'stixy')
     #      g = f.grants
     #      g.delete_if{|gg| gg.grantee.group=="AuthenticatedUsers"}
     #      g << AWS::S3::ACL::Grant.grant(:public_read)
     #      f.grants = g
     #      if AWS::S3::S3Object.acl(self.new_name, 'stixy', f)
     #        yield 1, self.public_uri if block_given?
     #      else
  # storage_state 1: didnd't exist or acl went wrong 
     #        yield 0, "Error acl #{id}" if block_given?
     #        self.update_attribute(:storage_state, 10)
     #      end
     #    else
     #      self.update_attribute(:storage_state, 10)
     #      yield 0, "Error #{id}" if block_given?
     #    end
     #  rescue => m
  # storage_state 11: something went wrong 
     #    self.update_attribute(:storage_state, 11)
     #    yield 0, "Error #{id}: #{m}" if block_given?
     #  end
     #end
  # storage_state 15: has been 9, but couldn't be moved to backup folder 
     #def new_access
     #  f = AWS::S3::S3Object.acl(self.new_name, 'stixy')
     #  g = f.grants
     #  g.delete_if{|gg| gg.grantee.group=="AuthenticatedUsers"}
     #  g << AWS::S3::ACL::Grant.grant(:public_read)
     #  f.grants = g
     #  AWS::S3::S3Object.acl(self.new_name, 'stixy', f)
     #  self.update_attribute(:storage_state, 12)
     #end
     # storage_state 20: backup exist and old is removed 
     # storage_state 30: Final. New exist and old is removed or backed up

     # Remove
     def regenerate
       image = self.parent
       options = image.attributes
       options[:thumbnails] = [self.attributes, image.thumb(:original).attributes]
       remote_file = ImageFileResource.new(options)
       remote_file.load(image.certificate)
       remote_file.save
       self.update_attribute(:storage_state, 14)
     end
