# Application Controller used to be replaced with Base Controller because of bug documented at http://dev.rubyonrails.org/ticket/6001
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include StixyRenderMethods
  include StixyBrowser

  class SignInError < StandardError #:nodoc:
  end
  
  class MiscError < StandardError
    attr_accessor :type, :title, :message, :status
    def initialize args={}
      @popup = args[:popup]   || false
      @type = args[:type]   || "UNSPECIFIED"
      @status = args[:status] || 200
      @title = args[:title] || nil
      @message = args[:message] || nil
    end
    
    def popup?
      @popup
    end
  end
  
  # Debug. Users need to clear cookie if old cookie is set
  rescue_from(CGI::Session::CookieStore::TamperedWithCookie) do |exception| 
    respond_to do |type|
      type.html { render :file => "#{RAILS_ROOT}/public/cookie_reser.html", :status => "500 Error" }
      type.all  { render :nothing => true, :status => "500 Error" }
    end
  end 
  
  # Shared error messages for controllers photo, personal thumbnails
  def image_errors m
    if m
      flash[:error] = case m
      when /Content type can't be blank/
        "You must first <b>select a photo to upload</b> by clicking on the button on the right of the text field bellow."
      when /Size is not included/		
        "The maximum allowed file size for photos is <b>4 MB</b>. If you need to add larger files, please upload it as a \"Document\", or resize the photo before uploading it."
      when /Content type is not included/
        "The file was <b>not recoginized as an image</b>. Please try with a different image, or possibly add the right extension."
      else
        "We're sorry! There was an <b>unspeciefied error</b> while uploading the photo to Stixy."
      end
      logger.error "EXCEPTION THROWN -- #{m.inspect}"
    end
  end
  
  
  rescue_from MiscError, :with => :render_error
    
  def render_error exception
    @title = exception.title
    @message = exception.message
    if exception.popup?
      render_as_popup do
        render :layout => "decorator-popup", :template => "/shared/popup_message" and return
      end
    else
      render :layout => false, :template => "/shared/message"
    end
  end  
  
  # --------------------------
  # Filters common to all controllers
  # --------------------------

  before_filter :supported_browsers, :page_size, :set_headers, :doc_type, :login_from_cookie, :set_session_id, :set_js_cookies
  
  # Initiate the Javascript logger (the class is placed in the "RAILS_ROOT/lib" directory)
  js_log_file = File.open(File.dirname(__FILE__) + "/../../log/js.log",'w')
  js_log_file.sync = true
  @@js_logger = JavascriptLogger.new(js_log_file)
  admin_log_file = File.open(RAILS_ROOT + "/log/admin.log",'w')
  admin_log_file.sync = true
  @@admin_logger = Logger.new(admin_log_file)
  
  def javascript_logger; @@js_logger end
  def admin_logger; @@admin_logger end
  
  
  layout "decorator-stixyboard"
  
  @@default_layout = nil
  
  # We need to store the session_id and if a user is autorized or not in the cookie.
  # This is so we can use it on the client side. The session_id is used by the flash upload,
  # and the authorized key is used for board navigation. None are a security risk.
  # The authorized key is only used to display the right info to a user. One can't alter it
  # and gain access to none authorized info. The session is can be retrived by a user anyway, by
  # decoding the cookie using base64.
  # Read about cookie sesions in rails at: http://www.neeraj.name/blog/articles/834-how-cookie-stores-session-data-in-rails
  # The session_id and the authorized key are read in public/all/default/002_stixy_init.js
  def set_js_cookies
    cookies[:stixy_sid] = session[:session_key]
    cookies[:stixy_authorized] = (current_user.authorized?).to_s
  end
  
  def set_session_id
    session[:session_key] ||= CGI::Session.generate_unique_id
  end
  
  def debug_logger
    log = Logger.new(File.open(File.join(RAILS_ROOT, 'log', 'board_filter_debug.log'), File::WRONLY | File::APPEND | File::CREAT))
    yield log
    log.close
  end
  
  # Catch all images that are missing
  def images
    render :nothing => true, :status => "404"
  end

  # --------------------------
  # Protected Methods
  # --------------------------
  
  protected
  	    
  # --------------------------
  # Private Methods
  # --------------------------

  private
  
  # First, see if user has accessed the board by board password and if so return the board
  # Else, see if user is authorized to the and if so return the board
  # Else, see if the board is public the and not password protected and if so return the board
  def get_authorized_board_common id, conditions_public_pwd, conditions_public
    return  Board.new if(id.to_i == 0)
    
    # Simplified authorization for development - just find the board if it exists without conditions
    # TODO: Implement proper user-board authorization when user system is fully set up
    board = Board.find_by_id(id) rescue nil
    return board if board
    
    # Return empty board if not found
    return Board.new
  end
  
  def get_authorized_board id
    return  get_authorized_board_common(id, "visible = '1'", "visible = '1' and pwd_protected = '0'")
  end

  def get_authorized_and_editable_board id
    return get_authorized_board_common(id, "visible = '1' and editable = '1'", "visible = '1' and editable = '1' and pwd_protected = '0'")
  end
  
  def guest_pwd_access? id
    return false unless session[:guest]
    return session[:guest].include?(id.to_s)
  end
  
  def set_headers
    #headers["Content-Type"] = "text/html; charset=utf-8"
    headers["X-UA-Compatible"] = "IE=7"
  end
  
  def choose_layout
    params[:popup] ? "decorator-popup" : @@default_layout || "decorator-stixyboard"
  end
  
  # signout action
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :signed_in, :domain => ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:session_domain]
    cookies.delete :auth_token
    session[:user_id] = nil
  end

  def login(user)
    self.current_user = User.authenticate(user[:login], user[:pwd])
    if self.current_user.authorized?
      cookies[:signed_in] = { :value => "true", :domain => ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:session_domain] }
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      session[:user_first_login] = self.current_user.first_login?
      self.current_user.update_attribute(:last_login_date, Time.now)
    end
  end
  
  def get_board
    return create_board if create_new_board?
    current_user.boards.find(params[:id]) rescue last_visited_board
  end

  def page_size
    session[:page_size] = 15 if session[:page_size].nil?
  end
end