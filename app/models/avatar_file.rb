class AvatarFile < AbstractFile

    has_attachment :storage => :file_system, 
        :path_prefix => 'public/system/avatars'
   
    # Shared extensions to AttachmentFu
    include AttachmentFuExtensions

    # Used for copying old names to new. Not to be used in production. Remove when done!!
    def base_name name
      "public/system/avatars/#{name}/#{filename}"
    end
   
end