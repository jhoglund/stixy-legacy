module Widgets::AbstractFileHelper
  # Base helper methods for file widgets
  
  def file_size_human(size)
    return "0 KB" if size.nil? || size == 0
    
    units = ['bytes', 'KB', 'MB', 'GB', 'TB']
    e = (Math.log(size) / Math.log(1024)).floor
    s = "%.1f" % (size.to_f / 1024**e)
    s.sub(/\.?0*$/, '') + ' ' + units[e]
  end
  
  def file_icon_class(content_type, filename = "")
    return "file-generic" if content_type.blank?
    
    case content_type.to_s.downcase
    when /image/
      "file-image"
    when /pdf/
      "file-pdf"
    when /msword|document/
      "file-document"
    when /excel|spreadsheet/
      "file-spreadsheet"
    when /powerpoint|presentation/
      "file-presentation"
    when /text/
      "file-text"
    when /zip|rar|tar|gz/
      "file-archive"
    else
      "file-generic"
    end
  end
  
end 