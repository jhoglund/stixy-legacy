class ImageFile < AbstractFile

    has_attachment :storage => :file_system,
        :path_prefix => 'public/system/images',
        :thumbnail_class => 'ThumbnailFile',
        :thumbnails => { :original => '600>', :t => '200>'}

    belongs_to  :user

    has_many  :library_photos_widget_instances
    has_many  :widget_instances, :through => :library_photos_widget_instances
    
    # Shared extensions to AttachmentFu
    include AttachmentFuExtensions
    
    # pulls up or creates the thumb record
    def thumb(size = :t)
      thumb = self.thumbnails.detect {|thumb| thumb.thumbnail.to_sym == size} if self.thumbnails
      thumb ||= (self.thumbnails << ThumbnailFile.new(:thumbnail => size.to_s, :filename => thumbnail_name_for(size.to_s), :content_type => self.content_type); self.thumbnails.last)
      return thumb
    end

    def original
      thumb(:original)
    end
                    
    def copy_attachments_to clone
      options = self.attributes
      options.merge!(self.certificate)
      options[:thumbnails] = [self.thumb(:t).attributes, self.thumb(:original).attributes ]
      options[:clones] = { :image => clone.full_filename,:t => clone.thumb(:t).full_filename,:original => clone.thumb(:original).full_filename }
      ImageFileResource.new.post(:copy, { :photo => options }) 
    end
    
    def self.remove_tmp
      # Find all files not accossiated with any user or widget and older than 0ne week
      orphans = find_by_sql "SELECT af.* from abstract_files AS af LEFT JOIN library_photos_widget_instances AS wi ON  wi.library_photo_id = af.id WHERE (af.user_id=0 OR af.user_id IS NULL) AND wi.widget_instance_id IS NULL AND type = 'ImageFile' AND updated_at < DATE_SUB(CURDATE(), INTERVAL 1 DAY);"
      orphans.each do |orphan|
        # This destroy all orphans (files not accossiated with any user or widget)
        # The origianl, as well as the thumbnails, are destroyed from the db and the files are removed from S3
        orphan.destroy
      end
    end
    
end

