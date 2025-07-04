class PublicController < Stixyboard
    require 'paginator'
    include BetaSignup
    session :off, :only => :is_server_up
    layout :choose_layout
    skip_before_filter :supported_browsers, :only => [:wrong_browser, :is_server_up]
    skip_before_filter :login_required
    caches_page :wrong_browser, :popup_layout 
    
    # This caused the script and style link tags to point to the version of the browser first visiting the page,
    # and thereby caching it. I.E <link type="text/css" href="/resources/default/ie_7.css">
    # This caused some display problems for other browsers.
    # caches_page :about_us, :this_is_stixy, :contact_us, :terms_of_service, :privacy_policy
        
    @@default_layout = "decorator-popup"
    
    def popup_layout
      @buttons = ''
      render :layout => "decorator-popup", :inline => "" and return
    end

    def wrong_browser
      render :layout => false 
    end
    
    # login screen action (both display and sign in)
    def signin
      login_user do |success|
        if success
          render_popup_result do |result|
            result.load << "if(Global.ui.canvas_content) top.Stixy.html.replace(Global.ui.canvas_content, '');"
            result.load << "top.location.replace('/');"
          end and return
        else
          render_as_popup do
            render :layout => "decorator-public" and return
          end
        end
      end
    end
    
    def signin_again
      begin
        signin_user
        if request.post?
          render_popup_result do |result|
            result.init << "parent.location.replace('#{stored_uri_or_default('/')}');"
          end and return
        end
      rescue
      end
      render_as_popup do
        render :layout => "decorator-public" and return
      end
    end
    
    def forgot_password
      reset_password        
      render_as_popup do
        render :layout => "decorator-public" and return
      end
    end
    

    # Performs user registration
    def signup
      @new_user = User.new
      if request.post?
        # If a non registered user has recieved an invitation but never accepted the invite, the user will already be in the database.
        # If so, the user will still have a status of PENDING. Then, update the user instead of create a new user
        # This is not secure since anyone could register in the name of someone else and get a hold of that persons invites
        # For this to be secure we need to implement a confirmation my mail system for new signups.
        @new_user = User.find_by_login_and_status(params[:user][:login], Status::PENDING) if params[:user]
        @new_user ||= User.new
        @new_user.attributes = params[:user]
        # do the user registration
        @terms_of_service = params[:user][:terms_of_service]
        @pwd_confirmation = params[:user][:pwd_confirmation]
        @login_confirmation = params[:user][:login_confirmation]
        @new_user.role_ids = [Role::USER] unless @new_user.in_role? Role::USER
        @new_user.status = Status::ACTIVE
        @new_user.created_by_id = current_user.id
        @new_user.updated_by_id = current_user.id
        @new_user.last_login_date = Time.now
        if @new_user.save
          logout
          self.current_user = @new_user
          create_welcome_board
          ActiveRecord::Base.silence {  Notifier.deliver_welcome_mail(self.current_user) }
          render_as_popup do
            render :layout => "decorator-public", :template => "public/how_stixy_works" and return
          end
        else
          render_as_popup do
            render :layout => "decorator-public", :template => "public/signup" and return
          end
        end
      else
        render_as_popup do
          render :layout => "decorator-public", :template => "public/signup" and return
        end
      end
    end
    
    # # Beta tester registration
    # def beta_signup
    #   if u=beta_signup_common
    #     beta_send_invite(u)
    #   end
    #   render_as_popup do
    #     render :layout => "decorator-public", :template => "public/beta_signup" and return
    #   end
    # end
    # 
    # # Beta tester registration
    # def launch_signup
    #   beta_signup_common(true)
    #   render_as_popup do
    #     render :layout => "decorator-public", :template => "public/launch_signup" and return
    #   end
    # end
    

    # signout action
    def signout
      logout
      redirect_to "/"
    end
    
    def redirect_to_signin
      redirect_to :controller => "signin" if ENV["RAILS_ENV"] == "production"
    end
    
    def blog
      redirect_to "http://blog.stixy.com"
    end
    
    def how_stixy_works
      render_as_popup do
        render :layout => "decorator-public" and return
      end
    end
    def this_is_stixy
      render_as_popup do
        render :layout => "decorator-public" and return
      end
    end
    def contact_us
      render_as_popup do
        render :layout => "decorator-public" and return
      end
    end
    def terms_of_service
      render_as_popup do
        render :layout => "decorator-public" and return
      end
    end
    def privacy_policy
      render_as_popup do
        render :layout => "decorator-public" and return
      end
    end
    def help
      render_as_popup do
        render :layout => "decorator-public" and return
      end
    end
    
    #BETA
    
    def signin_beta
      login_user do |success|
        if success
          redirect_to "/" and return
        else
          render :layout => "decorator-beta", :template => "public/signin_beta" and return
        end
      end
    end
    def forgot_password_beta
      reset_password
      render :layout => "decorator-beta", :template => "public/forgot_password"
    end
    def blog_beta
      redirect_to "http://blog.stixy.com"
    end
    def contact_us_beta
      render :layout => "decorator-beta", :template => "public/contact_us"
    end
    def terms_of_service_beta
      render :layout => "decorator-beta", :template => "public/terms_of_service"
    end
    def privacy_policy_beta
      render :layout => "decorator-beta", :template => "public/privacy_policy"
    end
    def help_beta
      redirect_to "/"
    end
    def how_stixy_works_beta
      redirect_to "/"
    end
    def this_is_stixy_beta
      redirect_to "/"
    end
    def signup_beta
      redirect_to "/"
    end
    

    # This url is used by Engine Yard for monitoring the up time of Stixy.
    # Don't change the name of this action.
    # Read more at: http://forum.engineyard.com/forums/6/topics/21
    def is_server_up
      logger.silence do
        Role.find(:first, :select => "id")
        render :layout => false
      end
    end
    
    # This url is used by Pingdom to monitor if Notifications and Emails are working.
    # Don't change the name of this action.
    def is_notifications_working
      logger.silence do
        notifications = Notification.find_reminders(Time.now-3600).size
        user_notifications = UserNotification.find_reminders(Time.now-3600).size
        emails = Email.count(:conditions => ["created_on < ?", Time.now-3600])
        if notifications == 0 and user_notifications == 0 and emails == 0
          render :layout => false, :inline => "Everything is working as expected"
        else
          logger.error("Notifications size: #{notifications}, User notifications size: #{user_notifications}, Email size: #{emails}")
          render :layout => false, :inline => "Notifications size: #{notifications}, User notifications size: #{user_notifications}, Email size: #{emails}", :status => 500
        end
      end
    end
 
    # This url is used by Pingdom to monitor for misc errors (like if upload to s3 doesn't work).
    # Don't change the name of this action.
    def misc_errors
      logger.silence do
        unless File.exists?(File.join(RAILS_ROOT, 'log', 'tmpError'))
          render :layout => false, :text => "Everything is working as expected"
        else
          render :layout => false, :text => "<pre>#{IO.read(File.join(RAILS_ROOT, 'log', 'tmpError'))}</pre>", :status => 500
        end
      end
    end
    
    def development   
      render :layout => false, :template => "development/#{params[:id]}", :content_type => "text/html"
    end
    
    def return_missing
      render :nothing => true, :status => "404"
    end
        
    def debug_browser
      set_session_browser
      render :text => "Browser type detected: #{session[:browser][:type].inspect}<br/>User Agent: #{request.env['HTTP_USER_AGENT']}<br/>Is supported: #{is_browser_supported?}"
    end
        
    private
    
    def login_user
      begin
        signin_user
        if request.post?
          if temp_board_exist?
            remove_temp_board
            @board = create_board
          else
      	    @board = last_visited_board
      	  end
          yield true
        end
      rescue
      end
      yield false
    end
    
    def reset_password
      @mail = ""
      if request.post?
        user = User.find_by_login(params[:user][:login])
        if (!user) 
          @mail = params[:user][:login]
          flash[:signin_missmatch] = "Sorry, we couldn't find a user with the e-mail address #{@mail}"
        else
          new_passwd = ""
          8.times { new_passwd << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
          user.pwd = new_passwd;
          user.save_without_validation
          begin
            ActiveRecord::Base.silence { Notifier::deliver_reset(user, new_passwd) }
            logger.info("Password has been reset for #{user.login}, and the new password is #{new_passwd}")
          rescue
            @status = :error 
          end 
          @reset = true
        end
      end        
    end
        
    def signin_user
      @user = User.new(params[:user])
      if request.post?
        logout
        login(params[:user])
        if logged_in?
          return
        else
          flash.now[:signin_missmatch] = "The e-mail address (#{params[:user][:login]}) and password doesn't match"
          raise SignInError.new
        end
      end
    end
    
    
end
