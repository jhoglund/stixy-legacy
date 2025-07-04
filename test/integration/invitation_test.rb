require "#{File.dirname(__FILE__)}/../test_helper"

class InvitationTest < ActionController::IntegrationTest
  fixtures :invites, :users, :boards, :boardusers, :widget_instances, :library_photos_widget_instances, :widgets, :roles
  
  def setup
    ActionMailer::Base.deliveries = []
  end
  
  def test_invite_new_user
    jonas = new_session_as :jonas
    new_user = "test_#{rand(1000000).to_s}@stixy.com"
    jonas.post "board/create_invite", {:id => jonas.boards(:invite_board_jonas_only).id, :contacts => { "temp_12345" => new_user }, :msg => { :text => "this is a test text for adam" }}
    assert_equal 1, ActionMailer::Base.deliveries.size
    invite = User.find_by_login(new_user).pending_invitations.first
    guest = new_session
    guest.get "invitation", {:token => invite.reference_token}
    guest.assert_template "invitation/index"
    guest.get "invitation/join", {:token => invite.reference_token}
    guest.assert_template "invitation/join"
    guest.post "invitation/join", {:invite => {:reference_token => invite.reference_token}, :user => {:pwd => "pss", :pwd_confirmation => "password"}}
    guest.assert_template "invitation/join"
    guest.post "invitation/join", {:invite => {:reference_token => invite.reference_token}, :user => {:pwd => "", :pwd_confirmation => "password"}}
    guest.assert_template "invitation/join"
    guest.post "invitation/join", {:invite => {:reference_token => invite.reference_token}, :user => {:pwd => "pssssss", :pwd_confirmation => "password"}}
    guest.assert_template "invitation/join"
    guest.post "invitation/join", {:invite => {:reference_token => invite.reference_token}, :user => {:pwd => "password", :pwd_confirmation => "password"}}
    guest.assert_template "invitation/success"
    jonas.end_session
    guest.end_session
  end
  
  def test_invite_new_user_delete_and_reinvite
    Invite.delete_all
    jonas = new_session_as :jonas
    new_user = "test_new_user_delete_and_reinvite@stixy.com"
    jonas.post "board/create_invite", {:id => jonas.boards(:invite_board_jonas_only).id, :contacts => { "temp_12345" => new_user }, :msg => { :text => "this is a test text for adam" }}
    assert_equal 1, ActionMailer::Base.deliveries.size
    new_but_registred_user = User.find_by_login(new_user)
    invite = Invite.find(:first)
    assert_equal 1, Invite.find(:all).size
    jonas.post "board/board_options", {:id => jonas.boards(:invite_board_jonas_only).id, :board => { :title => "Test" }, :remove_invite => { invite.id.to_s => "1"} }
    assert_equal 0, Invite.find(:all).size
    jonas.post "board/create_invite", {:id => jonas.boards(:invite_board_jonas_only).id, :contacts => { new_but_registred_user.id.to_s => new_but_registred_user.id.to_s }, :msg => { :text => "this is second test" }}
    invite = new_but_registred_user.pending_invitations.first
    guest = new_session
    guest.get "invitation", {:token => invite.reference_token}
    guest.assert_template "invitation/index"
    # ActiveRecord::Base.logger.debug "ewewewewewe 11111"
    guest.post "invitation/join", {:invite => {:reference_token => invite.reference_token}, :user => {:pwd => "password", :pwd_confirmation => "password"}}
    guest.assert_template "invitation/success"
    jonas.end_session
    guest.end_session
  end

  def test_invite_existing_user_delete_and_reinvite
    Invite.delete_all
    jonas = new_session_as :jonas
    adam = new_session_as :adam
    jonas.post "board/create_invite", {:id => jonas.boards(:invite_board_jonas_only).id, :contacts => { users(:adam).id.to_s => users(:adam).id.to_s }, :msg => { :text => "this is a test text for adam" }}
    assert_equal 1, ActionMailer::Base.deliveries.size
    invite = Invite.find(:first)
    assert_equal 1, Invite.find(:all).size
    jonas.post "board/board_options", {:id => jonas.boards(:invite_board_jonas_only).id, :board => { :title => "Test" }, :remove_invite => { invite.id.to_s => "1"} }
    assert_equal 0, Invite.find(:all).size
    jonas.post "board/create_invite", {:id => jonas.boards(:invite_board_jonas_only).id, :contacts => { users(:adam).id.to_s => users(:adam).id.to_s }, :msg => { :text => "this is second test" }}
    invite = users(:adam).pending_invitations.first
    adam.get "invitation", {:token => invite.reference_token}
    adam.assert_template "invitation/index"
    adam.get "invitation/join", {:token => invite.reference_token}
    adam.assert_template 'layouts/decorator-popup'
    adam.assert_response :success
    jonas.end_session
    adam.end_session
  end
  
  def test_invite_not_logged_in
    jonas = new_session_as :jonas
    jonas.post "board/create_invite", {:id => jonas.boards(:invite_board_jonas_only).id, :contacts => { users(:adam).id => users(:adam).id }, :msg => { :text => "this is a test text for adam" }}
    assert_equal 1, ActionMailer::Base.deliveries.size
    invite = Invite.find(:first, :conditions => "accepted_user_id = #{users(:adam).id} and inviter_user_id = #{users(:jonas).id} and board_id = #{jonas.boards(:invite_board_jonas_only).id} and invitation_text = 'this is a test text for adam'")
    assert_equal invite.accepted_user, users(:adam) 
    guest = new_session
    guest.get "invitation", {:token => invite.reference_token}
    guest.assert_template "invitation/index"
    guest.get "invitation/join", {:token => invite.reference_token}
    guest.follow_redirect!
    guest.assert_template "public/signin"
    adam = new_session_as :adam
    adam.assert_equal adam.assigns(:board).id, jonas.boards(:invite_board_jonas_only).id
    adam.get "/"
    adam.assert_template "board/stixyboard"
    adam.assert_equal adam.assigns(:board).id, jonas.boards(:invite_board_jonas_only).id
    jonas.end_session
    adam.end_session
    guest.end_session
  end
 
  def test_invite_already_logged_in
    jonas = new_session_as :jonas
    maria = new_session_as :maria
    new_user = "test_#{rand(1000000).to_s}@stixy.com"
    jonas.post "board/create_invite", {:id => jonas.boards(:invite_board_jonas_only).id, :contacts => { users(:maria).id => users(:maria).id, "temp_12345" => new_user  }, :msg => { :text => "this is a test text for maria" }}
    assert_equal 2, ActionMailer::Base.deliveries.size
    invite = Invite.find(:first, :conditions => "accepted_user_id = #{users(:maria).id} and inviter_user_id = #{users(:jonas).id} and board_id = #{jonas.boards(:invite_board_jonas_only).id} and invitation_text = 'this is a test text for maria'")
    assert_equal invite.accepted_user, users(:maria) 
    maria.get "invitation", {:token => invite.reference_token}
    maria.assert_template "invitation/index"
    maria.get "invitation/join", {:token => invite.reference_token}
    maria.assert_select "meta#popup_result", true
    maria.assert_equal maria.assigns(:board).id, jonas.boards(:invite_board_jonas_only).id
    jonas.end_session
    maria.end_session
  end

end
