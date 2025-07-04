module StixyBrowser
  def supported_browsers
    # Skip browser check if test_browser_support parameter is present
    return true if !params[:test_browser_support].nil?
    
    # Skip browser check in development environment to allow modern browsers
    return true if ENV["RAILS_ENV"] == "development"
    
    # Only enforce browser checks in production
    return true unless ENV["RAILS_ENV"] == "production"
    
    set_session_browser
    if not is_browser_supported?
      render :layout => false, :template => "public/wrong_browser" and return false
    end
  end
  
  def set_session_browser
    session[:browser] ||= {}
    # Always detect browser type
    session[:browser][:type] ||= browser?
    session[:browser][:is_old_ie] ||= (session[:browser][:type] == "ie_6" || session[:browser][:type] == "ie_5.5")
    set_browser_object
    return session[:browser][:type] 
  end
  
  def set_browser_object
    @browser = Browser.new(session[:browser][:type], session[:browser][:is_old_ie])
  end
  
  def is_browser_supported?
    %w{ie_6 ie_7 firefox chrome safari webkit robot}.include? session[:browser][:type]
  end
  
  def doc_type
    set_session_browser
    @doc_type = ( session[:browser][:is_old_ie]) ? 
      '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 transitional//EN">' : 
      '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
  end
  
  def platform?
    case request.env["HTTP_USER_AGENT"]
      when /Windows/ then "win"
      when /Mac/ then "mac"
    end
  end
  
  def browser?
    #session
    user_agent_string = request.env["HTTP_USER_AGENT"]
		#Check browser
    if user_agent_string =~ /Gecko/ && gecko_version? then "firefox"
    elsif user_agent_string =~ /MSIE 8/ then "ie_7" # We emulates IE 7 mode for IE 8, so we want to server the IE 7 specific files
    elsif user_agent_string =~ /MSIE 7/ then "ie_7"
    elsif user_agent_string =~ /MSIE 6/ then "ie_6"
    elsif user_agent_string =~ /MSIE 5.5/ then "ie_5.5"
    elsif user_agent_string =~ /MSIE 5/ then "ie_old"
    elsif user_agent_string =~ / Chrome\// then "chrome"
    elsif user_agent_string =~ /Safari/ && safari_version? then "safari"
    elsif user_agent_string =~ /AppleWebKit/ then "webkit"
    elsif user_agent_string =~ /bot|crawler|seeker|slurp/i then "robot"
    else "other"
    end
  end
  
  def gecko_version?
  	#Get useragentstring
  	agent = request.env["HTTP_USER_AGENT"]
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
  
  def safari_version?
    version = request.env["HTTP_USER_AGENT"].scan(/Version\/(\d)\.?/i)[0].to_s
    #Check if the version is 3 or higher
    if version >= "3"
      true 
    else 
      false
    end
  end
  
  class Browser
    attr_reader :type, :is_old_ie
    def initialize type, is_old_ie
      @type = type
      @is_old_ie = is_old_ie
    end
  end
  
end