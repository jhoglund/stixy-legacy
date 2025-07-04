class DocumentFile < AbstractFile
    
    has_attachment :storage => :file_system, :path_prefix => 'public/system/documents'
    
    has_many  :library_documents_widget_instances, :foreign_key => 'library_document_id'
    has_many  :widget_instances, :through => :library_documents_widget_instances

    # Shared extensions to AttachmentFu
    include AttachmentFuExtensions
    
    # Used for copying old names to new. Not to be used in production. Remove when done!!
    def base_name name
      "content/documents/#{name}/#{filename}"
    end
    
    def copy_attachments_to clone
      options = self.attributes
      options.merge!(self.certificate)
      options[:clone] = clone.full_filename
      DocumentFileResource.new.post(:copy, { :document => options }) 
    end
    
    def self.remove_tmp
      orphans = find_by_sql "SELECT af.* from abstract_files AS af LEFT JOIN library_documents_widget_instances AS wi ON  wi.library_document_id = af.id WHERE (af.user_id=0 OR af.user_id IS NULL) AND wi.widget_instance_id IS NULL AND type = 'DocumentFile' AND updated_at < DATE_SUB(CURDATE(), INTERVAL 1 DAY);"
      orphans.each do |orphan|
        # This destroy all orphans (files not accossiated with any user or widget)
        # The origianl, as well as the thumbnails, are destroyed from the db and the files are removed from S3
        orphan.destroy
      end
    end
    
end