module AuthenticatedSystem
  protected
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      current_user && current_user.authorized?
    end
    
    # Accesses the current user from the session.
    # Jonas added environment test because of problem of getting the right user for the widgets/default_controller_test.rb
    def current_user
      #@current_user || (session[:user_id] && User.find_by_id(session[:user_id])) || User.find(1)
      ((ENV["RAILS_ENV"]=="test") && @current_user && (@current_user.id != session[:user_id])) ? get_user : @current_user ||= get_user
    end
    
    def get_user
      (session[:user_id] && User.find_by_id(session[:user_id])) || get_default
    end
    
    def get_default
      u = User.new("salt"=>"yo-ma-salt", "city"=>"", "status"=>"1", "created_on"=>"2006-09-30 07:32:32", "pref_send_email_and_mobile"=>"0", "zip"=>"", "crypted_password"=>nil, "updated_by_id"=>"0", "last_login_date"=>"2007-08-23 13:09:04", "updated_on"=>"2007-08-23 11:09:04", "remember_token_expires_at"=>"2007-09-27 00:43:40", "pref_ui_board_options"=>"0", "country"=>"", "time_offset"=>"0", "created_by_id"=>"0", "id"=>"1", "pref_ui_widget_tray"=>"1", "description"=>"", "pref_disable_flash_upload"=>"0", "remember_token"=>"1571cb936039d1282752854dbcb78a72dd0cd736", "pref_enable_grag_drop"=>"0", "phone"=>"", "nick_name"=>"", "pref_photo_auto_upload"=>"1", "first_name"=>"Public", "daylight_savings"=>"0", "address"=>"", "last_name"=>"Guest", "login"=>"guest", "pref_ui_board_list"=>"0", "mobile_phone"=>"", "state"=>"", "email"=>"guest")
      u.id=1
      return u
    end
   
    
    
    # Store the given user in the session.
    def current_user=(new_user)
      session[:user_id] = (new_user.nil? || new_user.is_a?(Symbol)) ? nil : new_user.id
      @current_user = new_user
    end
    
    # Check if the user is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_user.login != "bob"
    #  end
    def authorized?
      true
    end
        
    # if the user session has been canceled, but the client has an authenticated status of true
    def lost_session?
      session_lost = cookies[:signed_in]=="true" && !logged_in?
      cookies.delete :signed_in, :domain => ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:session_domain]  if session_lost
      return session_lost
    end
    
    def session_is_lost
      if lost_session?
        if request.xhr?
          raise MiscError.new(:type => "LOST_SESSION", :message => "Your not signed in. Please sign in again.")
          return false
        else
          @board = Board.new
          store_location
          params[:controller] = "public"
          params[:action] = "signin_again"
          redirect_to(params) 
          return false
        end
      else
        return true
      end
    end

    def login_required
      username, passwd = get_auth_data
      self.current_user ||= User.authenticate(username, passwd) || :false if username && passwd
      if logged_in? && authorized?
        return true
      elsif (params[:action]!="index") && (PublicController.public_method_defined?(params[:action]))
        params[:controller] = "public"
        redirect_to(params)
        # if a public fallback method exist, it will return true 
        # to allow for public version of a protected action 
        return true
      else
        access_denied
      end
    end
    
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |accepts|
        accepts.html do
          store_location
          params[:controller] = "signin"
          params[:action] = "index"
          redirect_to(params) and return false
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end  
    
    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.request_uri
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default="/", &block)
      if session[:return_to]
        redirect_to(session[:return_to])
        session[:return_to] = nil
      elsif block_given?
        yield default
      else  
        redirect_to(default)
      end
    end
    
    # Get stored uri or default.
    def stored_uri_or_default(default)
      uri = session[:return_to] || default
      session[:return_to] = nil
      return uri
    end
    
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # When called with before_filter :login_from_cookie will check for an :auth_token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      return unless cookies[:auth_token] && !logged_in?
      user = User.find_by_remember_token(cookies[:auth_token])
      if user && user.remember_token?
        user.remember_me
        self.current_user = user
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
        cookies[:signed_in] = { :value => "true", :domain => ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:session_domain] }
      end
    end

  private
    @@http_auth_headers = %w(X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION Authorization)
    # gets BASIC auth info
    def get_auth_data
      auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
      auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
      return auth_data && auth_data[0] == 'Basic' ? Base64.decode64(auth_data[1]).split(':')[0..1] : [nil, nil] 
    end
end
