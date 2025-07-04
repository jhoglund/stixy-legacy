module ActionView::Helpers::UrlHelper
  #def link_to_with_enhancment(*args)
  #  link_to_without_enhancment(*args)
  #end
  #alias_method_chain :link_to, :enhancment
  
  def link_to_with_special_logging(*args)
    logger.debug "link_to called with args: #{args.inspect}" if logger
    link_to_without_special_logging(*args)
  end
  alias_method_chain :link_to, :special_logging
  
  def testar
    return "test funka"
  end
  
end