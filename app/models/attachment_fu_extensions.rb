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
  
  # Ensure a flat public path exists for legacy URL compatibility
  def ensure_flat_public_path
    # Only for file system storage
    return unless respond_to?(:full_filename) && File.exist?(full_filename)
    
    # Create flat path for the current file
    create_flat_path_for_file
    
    # If this is a parent image, also create flat paths for all thumbnails
    if respond_to?(:thumbnails) && thumbnails.any?
      thumbnails.each do |thumb|
        # Use send to call the private method on thumbnails
        thumb.send(:create_flat_path_for_file) if thumb.respond_to?(:full_filename) && File.exist?(thumb.full_filename)
      end
    end
  end
  
  private
  
  def create_flat_path_for_file
    flat_dir = File.join(Rails.root, 'public', 'system', self.class.to_s.underscore.gsub('_file', '') + 's', id.to_s)
    FileUtils.mkdir_p(flat_dir)
    flat_path = File.join(flat_dir, filename)
    unless File.exist?(flat_path)
      begin
        FileUtils.ln_sf(full_filename, flat_path)
        Rails.logger.info "Created flat path symlink: #{flat_path} -> #{full_filename}"
      rescue => e
        Rails.logger.warn "Failed to create symlink, copying instead: #{e.message}"
        FileUtils.cp(full_filename, flat_path)
        Rails.logger.info "Created flat path copy: #{flat_path}"
      end
    end
  end
  
end