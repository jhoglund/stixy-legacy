INVITE_MESSAGE = <<-MESSAGE
Hi!

And welcome as a beta tester at Stixy. It feels great to have you as part of our team! \
Go ahead and create, collaborate, and share with friends, family or colleagues. \
Any bugs you may find, please report these to bugs@stixy.com. \
Any other feedback you want to send, please send an e-mail to feedback@stixy.com.
MESSAGE

module BetaSignup
  
  def beta_invite_mail beta_tester=nil, invite_user=nil, board=nil, message=nil
    unless @invite = Invite.find_by_accepted_user_id_and_inviter_user_id(beta_tester.user.id, invite_user.id)
      @board = board.copy
      @board.boardusers.create!(:user => invite_user)
      @invite = @board.invites.build(:updated_by =>  invite_user, :accepted_user => beta_tester.user)
      @invite.invitation_text = message if message
      ActiveRecord::Base.silence { Notifier::deliver_invite(@invite,  invite_user)} if @invite.save!
      admin_logger.info("Invitation sent on #{@invite.created_on.strftime("%B %d, %Y %I:%M %p")} to #{beta_tester.user.login} (#{beta_tester.user.id}), for board #{@board.id}, with token #{@invite.reference_token}")
    else
      Invite.reminder_mail(@invite)
    end
    return beta_tester
    rescue Exception => msg
      beta_tester.user.errors.add_to_base "We sorry, there was a problem with the registration of new beta account. Please try again later"
      admin_logger.info("ERROR #{Time.now.strftime("%B %d, %Y %I:%M %p")}: Couldn't send invitation. Message: #{msg}")
      return beta_tester
  end  
  
  # Beta tester registration
  def beta_signup_common notify_only=false
    @beta_tester = BetaTester.new
    @beta_tester.user = User.new
    if request.post?
      unless @beta_tester = BetaTester.find_by_user_login(params[:beta_tester][:login])
        @beta_tester = BetaTester.new(:comment => params[:beta_tester][:comment], :notify_only => (notify_only ? 1:0), :created_by_id => current_user.id, :updated_by_id => current_user.id)
        @beta_tester.user = User.create(:role_ids => [Role::USER], :pwd => "temp_beta_pwd", :login => params[:beta_tester][:login], :login_confirmation => params[:beta_tester][:login], :email => params[:beta_tester][:login], :time_offset => params[:beta_tester][:time_offset], :status => Status::PENDING, :created_by_id => current_user.id, :updated_by_id => current_user.id)
        @beta_tester.save!
        flash[:new_invite] = true
      end
      flash[:existing_invite] = true
    end
    return @beta_tester
    rescue Exception => msg
      @beta_tester.user.errors.add_to_base msg
      return @beta_tester
  end
  
  def beta_send_invite beta_testers=[], message=INVITE_MESSAGE
    if request.post?
      beta_testers = [beta_testers] if beta_testers.class!=Array
      invite_user = User.find_by_login("beta@stixy.com")
      invite_board = Board.find(459).copy
      invite_board.boardusers.destroy_all
      beta_testers.each do |beta_tester|
        user_login = beta_invite_mail(beta_tester, invite_user, invite_board, message)
        yield user_login if block_given?
      end
      return beta_testers
    end
  end
  
end


