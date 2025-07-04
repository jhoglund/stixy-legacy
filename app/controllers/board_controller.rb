class BoardController < Stixyboard
  before_filter :login_required
  before_filter :session_is_lost

  require 'resolv'
  require 'timeout'
  
# POPUPS
  def invite
    @board = current_user.boards.find(params[:id]) rescue (render_as_popup do
      @board = Board.find(params[:id])
      @feature_partial = "/board/invite"
      render :layout => "decorator-feature", :template => "public/invite" and return
    end)
    render_as_popup
  end
  
  def option
    @board = current_user.boards.find(params[:id]) rescue (render_as_popup do
      @board = Board.find(params[:id])
      @feature_partial = "/board/option"
      render :layout => "decorator-feature", :template => "public/option" and return
    end)    
    render_as_popup
  end

  # updates assorted board options and returns to options screen
  def board_options
    @board = current_user.boards.find(params[:id]) rescue (render_popup_close and return)
    current_user.board_modified(@board)
    if params[:board]
      @board.updated_by = current_user
      if disable_board = params[:board][:dodelete] == "yes"
        disable(@board)
      else
        # Reset password so it's not displayed in the pwd field or stored in the db
        params[:board][:pwd] = "" if params[:board][:pwd_protected] == "0"
        @board.tag_with(params[:tag_list], current_user.id) unless params[:tag_list].nil?
        params[:board].delete(:dodelete)
        @me = disable_user(params[:remove_user], @board, current_user)
        destroy_invite(params[:remove_invite])
        if @board.update_attributes(params[:board]) and not @me
          @status = :success
        end
      end
    end
    # Expire cached
    expire_fragment("widgets/todo/user_list/#{@board.id}")
    expire_fragment("board/board_options/#{@board.id}")
    render_popup_result do |result|
      if disable_board and first_board = current_user.boards.find(:first)
        result.load << "Global.board.navigate(#{first_board.id});"
      end
      result.load << "Global.board.updateBoardList();"
      result.load << "Global.board.updateBoardOptions();"
    end
  end	
	
  # creates invite
  def create_invite
    begin; @board = current_user.boards.find(params[:id])
    rescue; render_popup_close and return end
    unless params[:contacts].nil?
      @invite_contacts = params[:contacts].delete_if{|k,v| v=="0"}
      @invite_contacts.each do |key,value|
        if key.include?("temp_")
          begin
            new_user = true
            @user_to_invite = User.new(:role_ids => [Role::USER], :pwd => "temppwd", :pwd_confirmation => "temppwd", :login => value, :login_confirmation => value, :email => value, :status => Status::PENDING, :created_by_id => current_user.id)
        	  @user_to_invite.save!
          rescue => msg
            render_as_popup do
              render :layout => "decorator-popup", :template => "/board/invite" and return
            end
          end
        else
          new_user, @user_to_invite = false, User.find_by_id(value)
        end
        @invite = @board.invites.build(
          :invitation_text => params[:msg][:text],
          :updated_by =>  current_user,
          :accepted_user => @user_to_invite
        )
        begin
          if @invite.save!
            expire_fragment("board/board_options/#{@board.id}") # Expire cached
            current_user.contacts << @invite.accepted_user unless  current_user.contacts.include? @invite.accepted_user
            # sends mail using notifier. see environment.rb to configure mail servers
            begin
              ActiveRecord::Base.silence { Notifier::deliver_invite(@invite, current_user) }
            rescue
              @invite.accepted_user.destroy if new_user
              @invite.destroy
              @invite.errors.add_to_base("There was a problem sending the invitation due to the mail server. Please retry sending the invitation. If the problem continues, try at a later time or send an e-mail to <a href='mailto:bugs@stixy.com'>bugs@stixy.com</a>")
            end
          end
        rescue
          render_as_popup do
            render :layout => "decorator-popup", :template => "/board/invite" and return
          end
        end
      end
    end 
    render_popup_result
  end
  
  def trash_can
    @board ||= get_board
    render_as_popup do
      render :layout => "decorator-popup", :template => "board/trash_can" and return
    end
  end
  
  def copy
    @board = current_user.boards.find(params[:id])
    @clone = @board.copy(params[:includeUsers]=='true')
    @clone.users << current_user if @clone.users.empty? # If params[:includeUsers]==false
    @clone.title = "#{@clone.title} [copy]"
    @clone.save!
    render_popup_result do |result|
      result.load << "Global.board.updateBoardOptions();"
      result.load << "Global.board.updateBoardList(#{@clone.id});"
      result.load << "Global.board.navigate(#{@clone.id});"
    end and return
  end
  
  
  def recover_widgets
    begin
      @board = get_board
      if params[:widgets]
        widgets = [@board.widget_instances.find(*params[:widgets].keys)].flatten
        widgets.each do |widget|
          widget.to_instance.enable
        end
      end
      if params[:popupClose] == "true"
        cache_board_fragment(@board)
        render_popup_result do |result|
          result.init << "Global.board.navigate(#{@board.id});"
        end and return
      else
        @reload_board = true
        flash[:success] = "#{widgets.size} widget#{ if widgets.size!=1; "s" end} was recovered"
      end
    rescue
      flash[:error] = "We couldn't recover the widgets. Please try again. If you still experience a problem, please contact us at <a href='mailto:bugs@stixy.com'>bugs@stixy.com</a>."
    end
    trash_can
  end
  
  def delete_widgets
    begin
      @board = get_board
      if params[:widgets]
        widgets = [@board.widget_instances.find(*params[:widgets].keys)].flatten
        widgets.each do |widget_instance|
          widget_instance.update_attribute(:status, Status::DELETED)
        end
      end
      flash[:success] = "#{widgets.size} widget#{ if widgets.size!=1; "s" end} was deleted"
      @reload_board = true
    rescue => msg
      flash[:error] = "We couldn't delete the widgets. Please try again. If you still experience a problem, please contact us at <a href='mailto:bugs@stixy.com'>bugs@stixy.com</a>."
    end
    trash_can
  end
  
  
  # Add user to the list of invites in the invitation popup
  def invite_list_ajax
    @board = get_board
    #unless params[:email].blank?
		#  domain = params[:email].gsub(/.*?@/,"")
  	#	mx_record = Timeout::timeout(2) do
  	#		Resolv::DNS.new.getresources(domain, Resolv::DNS::Resource::IN::MX)
  	#	end
  	#	a_record = Timeout::timeout(2) do
  	#		Resolv::DNS.new.getresources(domain, Resolv::DNS::Resource::IN::A)
  	#	end
  	#	if mx_record.empty? || a_record.empty?
  	#		domain_error = true
  	#	else
  	#		domain_error = false
  	#	end
  	#end

	  user = (params[:email]) ? User.find_by_login(params[:email]) || TempUser.new(:id => params[:user_id], :email => params[:email]) : User.find(params[:user_id])
	  javascript_array_response do |item|
	    item << render_html_string(:partial => 'user_list', :object => user, :locals => {:appear_effect => false})
	    item << (params[:new_contact] ? render_html_string(:partial => 'invite_select_list', :object => user, :locals => {:new_contact => true}) : false)
	    item << current_user.contacts.empty?
			# item << (domain_error ? render_html_string(:partial => 'domain_error', :locals => {:appear_effect => false}) : false)
	  end
  end


  # resends the invitation mail to the given invitee
  def send_reminder_ajax
    return unless request.xhr?
    @board = Board.find(params[:id])
    @invite = Invite.find(params[:invite_id])
    token = @invite.reference_token
    begin
      ActiveRecord::Base.silence { Notifier::deliver_invite(@invite, current_user, current_user) }
    rescue
      flash[:error] = 'Unable to send mail. misconfigured' 
    end 
    flash.now[:invitation] = "The email was resent to #{@invite.accepted_user.display_name} to accept it at <a href='http://#{SERVER}/invitation/?token=#{token}'>http://#{SERVER}/invitation/?token=#{token}</a>"
    render :update do |page|
      page.replace_html 'options_shared_and_invited', :partial => 'options_shared_and_invited'
   end
  end
  
  def board_save_scroll
    @board = Board.find(params[:id])
    @board.save_scroll({:top => params[:attributes][:top], :left => params[:attributes][:left]})
    render :nothing => true
  end
  
  def board_user_update_ajax
    current_user.update_attributes(params[:attributes])
    render :nothing => true
  end


	## Send notification by email to users on this board.
	#  Also save the message in db.messages
	#
	def send_notification
    @board = Board.find(params[:id])
		users = @board.users
		text = params[:message]
		message = Message.new
		message.text = text
		message.messageable = @board
		message.sender_id = current_user.id

		# Save message and recipients and collect recipients emails to an array
		if message.save
			emails = []
			for user in users
				message.recipients << user
				emails << user.email.to_s + ", "
			end
		end

		# Arguments to notifier
		args = {
				:to => emails.to_s.chomp(", "),
				:from => "#{current_user.display_name} <member@stixy.com>",
				:reply => current_user.email,
				:content => text
		}
		# Send notification
		ActiveRecord::Base.silence { Notifier.deliver_board_notification(args, @board, current_user) }
		
    render :partial => '/board/board_notification'
	end

  
  #def send_notification
  #  render :partial => '/board/board_notification'
  #end
  
  private
  
  def not_cached_stixyboard
    return (current_user.authorized? || temp_board_exist? || params[:id]=="0") ? true : false
  end  
  
  def restrict_invites?
    new_contacts_size = @invite_contacts.collect{|k,v| k.include? "temp_" }.size
    (new_contacts_size + current_user.invited_by.size) > 5
  end
  
  def disable_user(params=nil, board=nil, updater=nil)
    return if params.nil?
    me = false
    params.delete_if{|k,v| v == "0" }.each do |u|
      begin
        user = board.boardusers.find(:first, :conditions => ["user_id=?",u.first])
        me = true if u.first.to_i == current_user.id
        user.update_attributes(:status => Status::DISABLED, :updated_by => updater)
      rescue
        return nil
      end
    end
    return me
  end

  def destroy_invite(params=nil)
    return nil if params.nil?
    params.delete_if{|k,v| v == "0" }.each do |i|
      begin
        invite = Invite.find(i.first)
        invite.destroy
      rescue
        return nil
      end
    end
  end
    
  # board delete implementation 
  def disable board
    board.status = Status::DISABLED
    board.boardusers.update_all("status = #{Status::DISABLED}")
    board.invites.update_all("status = #{Status::DISABLED}")
    board.updated_by = current_user
    board.save
  end
  
  class TempUser < User
    attr_accessor :full_name, :display_name, :id, :last_login_date
		def initialize p={}
			self.display_name = p[:email]
			self.full_name = nil
			self.last_login_date = nil
			self.id = (p[:id]=="0") ? "temp_#{self.object_id}" : p[:id]
			super(p)
		end
  end


end
