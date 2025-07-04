require "cgi"

# The following code is a work-around for the
# Flash 8 bug that prevents our multiple file uploader
# from sending the _session_id.  Here, we hack the
# Session#initialize method and force the session_id
# to load from the query string via the request uri. 






#class CGI::Session
#  alias original_initialize initialize
#  def initialize(request, option = {})
#    session_key = option['session_key'] || '_session_id'
#    query_string = if (qs = request.env_table["QUERY_STRING"]) and qs != ""
#      qs
#    elsif (ru = request.env_table["REQUEST_URI"][0..-1]).include?("?")
#      ru[(ru.index("?") + 1)..-1]
#    end
#    if query_string and query_string.include?(session_key)
#      option['session_key'] = query_string.scan(/#{session_key}=(.*?)(&.*?)*$/).flatten.first
#    end
#    original_initialize(request, option)
#  end
#    
#  def session_key
#    @session_key ||= CGI::Session.generate_unique_id
#    @session_key
#  end
#  
#end
#
#class CGI::Session::CookieStore
#  alias original_initialize initialize
#  def initialize(session, options = {})
#    @session_key = options['session_key']
#    original_initialize(session, options)
#  end
#end

class CGI::Session
  alias original_initialize initialize
  def initialize(request, option = {})
    session_key = option['session_key'] || '_session_id'
    query_string = if (qs = request.env_table["QUERY_STRING"]) and qs != ""
      qs
    elsif (ru = request.env_table["REQUEST_URI"][0..-1]).include?("?")
      ru[(ru.index("?") + 1)..-1]
    end
    if query_string and query_string.include?(session_key)
      option['session_data'] = CGI.unescape(query_string.scan(/#{session_key}=(.*?)(&.*?)*$/).flatten.first)
    end
    original_initialize(request, option)
  end
  
end

class CGI::Session::CookieStore
  alias original_initialize initialize
  def initialize(session, options = {})
    @session_data = options['session_data']
    original_initialize(session, options)
  end

  def read_cookie
    @session_data || @session.cgi.cookies[@cookie_options['name']].first
  end
end
