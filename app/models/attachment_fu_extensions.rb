module AttachmentFuExtensions
  
  def require_authentication?
    false  # Local files don't require authentication
  end
  
  # Overrides AttachmentFu's attachment_path_id method.
  # The attachment ID used in the full path of a file
  def attachment_path_id
    ((respond_to?(:parent_id) && parent_id) || id || 0).to_i
  end
  
  # Alias - returns the public URL for local file system storage
  def public_uri
    if respond_to?(:public_filename) && public_filename
      public_filename
    else
      "/system/#{self.class.to_s.underscore.gsub('_file', '')}s/#{id}/#{filename}"
    end
  end
  
end