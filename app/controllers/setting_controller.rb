class SettingController < Stixyboard
  before_filter :session_is_lost
  before_filter :login_required

  def index
    render_as_popup and return
  end
  
  def update
    @prefils = params[:user]
    if current_user.update_attributes(params[:user])
      @board = last_visited_board
      render_popup_result do |result|
        result.init << "Global.features.Upload.prototype.global.flash_enabled=#{(current_user.pref_disable_flash_upload==0)};"
        result.load << "Global.board.updateBoardList();"
        result.load << "Global.board.updateBoardOptions();"
        result.load << "Global.board.updateUtilityNav();"
      end
    else
      flash[:error] = 'New settings couldn\'t be saved'
      render_as_popup do
        render :layout => "decorator-popup", :action => 'index' and return
      end
    end
  end

  skip_before_filter :supported_browsers, :login_from_cookie, :set_session_id, :login_required, :session_is_lost, :only => :create
  verify :params => "avatar", :method => "post", :only => :create, :redirect_to => '/'
  def create
      # An empty response is is expected with a 'Location' header value:
      respond_to do |format|
        format.html { head :method_not_allowed }
        format.xml { 
          user = User.find(params[:avatar][:user_id])
          # if id attribute is present in remote call, then update method is called
          #  - to force using create, user remote_id
          remote_type = params[:avatar].delete('type') # prevents mass-asignment warning
          if user.personal_image
            user.personal_image.destroy
            user.personal_image.reload
          end
          @image = user.build_personal_image
          @image.attributes = params[:avatar]
          @image.user = user
          @image.user_authorized = user.authorized?
          @image.save!
          headers['Location'] = "http://stixy.com/setting/#{@image.id}"
          render :text => '', :status => :created 
        }
      end
  end
  
  # Upload icon popup
  def upload
    image_errors(params[:error])
    render :layout => 'decorator-popup'
  end
  
  # After upload action returns from upload server for non flash uploads
  def after_upload
    render_popup_close
  end
  
  def ajax_personal_image
    current_user.reload
    render :partial => "personal_image"
  end
  
  def ajax_remove_personal_image
    current_user.personal_image.destroy
    ajax_personal_image
  end
  
	def deactivate_user_account
		# Collect all boards for user and set status to
		# CANCELED if user is alone on the board.
		all_boards = current_user.boards
		for board in all_boards
			if board.users.size <= 1
				board.status = Status::CANCELED
				board.save
			end
		end
		# Set status for current user and his/hers
		# boardusers, invitations, invited_by, user_notifications to Canceled
		current_user.deactivate!
		current_user.memberships.deactivate!
		current_user.boardusers.update_all("status = #{Status::CANCELED}")
		current_user.invitations.update_all("status = #{Status::CANCELED}")
		current_user.user_notifications.update_all("status = #{Status::CANCELED}")

		
		# Logout current user and redirect to index (welcome)
##		if current_user.status == Status::CANCELED
		logout	
    render_popup_result do |result|
		  result.init << "parent.location.replace('/welcome');"
    end and return
##		end
	end
  
	def deactivate_account
	  render_as_popup
  end

end
