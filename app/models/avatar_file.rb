class AvatarFile < AbstractFile

    has_attachment :storage => :s3, 
        :s3_access => :public_read, 
        :path_prefix => 'content/avatars'
   
    # Shared extensions to AttachmentFu
    include AttachmentFuExtensions

    # Used for copying old names to new. Not to be used in production. Remove when done!!
    def base_name name
      "content/avatars/#{name}/#{filename}"
    end
   
end