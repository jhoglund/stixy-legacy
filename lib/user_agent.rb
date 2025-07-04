module UserAgent
 
  protected
  
  def browser_info(user_agent)
    browser = {
          :platform => nil,
          :browser => nil
        }
    #Firefox   
    if user_agent =~ /Gecko/ && gecko_version?(user_agent)
      browser[:browser] = "Firefox " + user_agent.scan(/[Firefox].\/(\d.+)/i).to_s
      browser[:platform] = get_platform(user_agent)
    #Internet Explorer
    elsif user_agent =~ /MSIE/
      browser[:browser] = "Internet Explorer " + user_agent.scan(/MSIE ([\d\.]+)/i).to_s
      browser[:platform] = get_platform(user_agent)
    #Unsupported browser
    else
      browser[:browser] = "Unsupported browser"
      browser[:platform] = get_platform(user_agent)
    end
    
    return browser
  end
  
  #Make browser_info available for controllers and views
  def self.included(base)
    base.send :helper_method, :browser_info
  end
  
  private
  
  #Check gecko version for Firefox
  def gecko_version?(agent)
  	if agent =~ /rv:/
  		#Split useragentstring
			agent = agent.split("rv:")[1]
			#Slice to get the rv version
			version = agent.slice(0,3)
			#Check if the version is 1.8 or higher
			if version >= "1.8"
				return true 
			else 
				return false
			end
		else
			return false
  	end
  end
  
  #Get Platform
  def get_platform(user_agent)
    if user_agent =~ /Win/i
      platform = "Windows"
    elsif user_agent =~ /Mac OS X/i
      platform = "Mac OS X"
    elsif user_agent =~ /Mac/i
      platform = "Mac"
    elsif user_agent =~ /Ubuntu/i
      platform = "Ubuntu Linux";
    elsif user_agent =~ /Linux/i
      platform = "Linux";
    elsif user_agent =~ /SunOS/i
      platform = "Sun Solaris";
    elsif user_agent =~ /BSD/i
      platform = "FreeBSD";
    elsif user_agent =~ /Gentoo/i
      platform = "Gentoo";
    else
      platform = "Other"
    end
  end
    
end
