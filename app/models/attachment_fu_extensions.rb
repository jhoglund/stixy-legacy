require 'aws/s3'
module AttachmentFuExtensions
  include AWS::S3
  
  def require_authentication?
    attachment_options[:s3_access] == :authenticated_read
  end
  
  # Overrides AttachmentFu's attachment_path_id method.
  # The attachment ID used in the full path of a file
  def attachment_path_id
    encode(((respond_to?(:parent_id) && parent_id) || id).to_s)
  end
  
  # Alias
  def public_uri
    unless require_authentication?
      s3_url
    else
      authenticated_s3_url(:expires_in => 3.minute.to_i)
    end
  end
  
end