class InvitationController < Stixyboard
  # this controller is for anonymous users, only, in fact signout is enforced
  # so skip authentication please
  
  skip_before_filter :login_required
  
  #model :user
  # do security check to prevent url spoofing against session for each controller except entry on
 # before_filter :validate , :except  => [:index] 

  # entry point of controller
  # validates that invite exists, has a valid token, that its still in PENDING state
  # if everything is cosher with this invite, puts it in session and renders view
  def index
    render_as_popup do
      msg, @invite = fetch_invitation params[:token]
      flash.now[:error] = msg if msg
      render :layout => "decorator-public", :template => "/invitation/index" and return
    end
  end
  
  def success
    render_as_popup do
      render :layout => "decorator-public" and return
    end
  end

  def join
    if request.post?
      @invite = Invite.find_by_reference_token(params[:invite][:reference_token])
      user_params = params[:user].merge({:login => @invite.accepted_user.login, :login_confirmation => @invite.accepted_user.login})
      @invite.accepted_user.attributes = user_params
      @invite.accepted_user.password_required = true
      @invite.accepted_user.status = Status::ACTIVE
      begin
        if @invite.accepted_user.save!
          login(user_params)
          session[:invite] = nil
          join_board
          create_welcome_board
          self.current_user.board_visited(@invite.board)
          ActiveRecord::Base.silence {  Notifier.deliver_welcome_mail(self.current_user) }
          render_popup_result do |result|
      		  result.init << "parent.location.replace('/invitation/success');"
          end and return
        end
      rescue => e
        @terms_of_service = params[:user][:terms_of_service]
        @pwd = params[:user][:pwd]
        @pwd_confirmation = params[:user][:pwd_confirmation]
        render_as_popup do
          render :layout => "decorator-public" and return
        end
      end
    else
      msg, @invite = fetch_invitation params[:token]
      flash.now[:error] = msg if msg
      if @invite
        if @invite.accepted_user.status == Status::ACTIVE
          join_board
          @invite.accepted_user.board_visited(@invite.board)
          if current_user.authorized?
            @board = @invite.board
            render_popup_result do |result|
        		  result.init << "parent.location.replace('/');"
            end and return
          else
            render_as_popup do
              redirect_to :controller => "public", :action => "signin", :popup => "true" and return
            end
          end
        end
      end
      render_as_popup do
        render :layout => "decorator-public" and return
      end
    end
  end
    
  def go_to_board
    @board = last_visited_board
    render_popup_and_update
  end
  
  def join_ajax
    msg, @invite = fetch_invitation params[:token]
    if @invite
      if @invite.accepted_user.status == Status::ACTIVE
        join_board
        params[:id] = @invite.board.id
        show_stixyboard
      end
    end
  end
    
  def signout
    logout
    redirect_to "/invitation/?popup=true&token=#{session[:invite][:token]}",:escape => false
  end
 
  protected 
  
  def join_board
    @invite.activate
    @invite.join_board
    # Expire cached
    expire_fragment("widgets/todo/user_list/#{@invite.board.id}")
    expire_fragment("board/board_options/#{@invite.board.id}")
  end
  
  # validates against spoofing of invite id in url
  def fetch_invitation token
    session[:invite] = {:token => token}
    invite = Invite.find_by_reference_token(token, :include => :board)
    if invite.nil?
      "We can't find this invitation. To get some help, try contacting the person who sent you the invitation."
    elsif current_user and invite.accepted_user != current_user and current_user.authorized?
      "#{current_user.nick_name}, this invitation is not for you. If you want to view this invitation, open it while you're not signed in as #{current_user.display_name}. <a href='/invitation/signout?popup=true'>Sign me out and open invitation</a>"
    elsif invite.status != Status::PENDING
      "You have already accepted this invitation. <a href='/signin?popup=true'>Sign in</a> to Stixy and go to Stixyboard Overview to find the Stixyboard connected to this invitation."
    elsif invite.board.status != Status::ACTIVE
      "The Stixyboard connected to this invitation is no longer active. To get some help, try contacting the person who sent you the invitation."
    else
      #session[:invite] = invite
      return nil, invite
    end
  end

end