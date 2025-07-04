require File.dirname(__FILE__) + '/../test_helper'
require 'board_controller'

# Re-raise errors caught by the controller.
class BoardController; def rescue_action(e) raise e end; end

class BoardControllerTest < Test::Unit::TestCase
  fixtures :users, :boards, :boardusers, :invites, :roles_users, :users_contacts
  def setup
    @controller = BoardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_ajax_board_shared_and_invited
    jonas = signin_as(:jonas)
    open_invite_popup(:id => 1)
    send_invite(:id => 1)
    get :index, {:id => 1}
    xhr :post, :board_shared_and_invited_ajax, {:id => 1}
    assert_response :success
    assert_template("board/_board_shared_and_invited")
  end
  
  def test_ajax_options_shared_and_invited
    jonas = signin_as(:jonas)
    open_invite_popup(:id => 1)
    send_invite(:id => 1)
    xhr :post, :options_shared_and_invited_ajax, {:id => 1}
    assert_response :success
    assert_template("board/_options_shared_and_invited")
  end
  
  def test_send_invite_no_accepted_user(options = {})
    jonas = signin_as(:jonas)
    assert_equal 8, Invite.find(:all).size
    assert_equal 0, users(:jonas).contacts.count
    # Contact 12 doesn't exist so an error should be thrown
    post :create_invite, {:id => 1, :contacts => { "12" => "12" }, :msg => { :text => "this is a test" }, :popup => true}
    assert_equal 8, Invite.find(:all).size
    assert_equal 0, users(:jonas).contacts.count
    assert_response :success
    assert_template("board/invite")
    assert_tag :tag => "div", :child => /We're sorry, we couldn't send the invitation./, :attributes => { :class => "inline-message-error" } 
  end
 
  def test_send_invalid_emai(options = {})
    jonas = signin_as(:jonas)
    assert_equal 8, Invite.find(:all).size
    assert_equal 0, users(:jonas).contacts.count
    # Contact 12 doesn't exist so an error should be thrown
    ActiveRecord::Base.logger.debug "LOGINTEST"
    post :create_invite, {:id => 1, :contacts => { "temp_123" => "1.dd.com" }, :msg => { :text => "this is a test" }, :popup => true}
    ActiveRecord::Base.logger.debug "LOGINTEST"
    assert_equal 8, Invite.find(:all).size
    assert_equal 0, users(:jonas).contacts.count
    assert_response :success
    assert_template("board/invite")
    assert_tag :tag => "div", :child => /We're sorry, we couldn't send the invitation./, :attributes => { :class => "inline-message-error" } 
  end
   
  def test_delete_board
    adam = signin_as(:adam)
    board = adam.boards.find(:first)
    start_size = adam.boards.size
    post(:board_options, {:id => board.id, :board => {:dodelete => "yes"}})
    adam.boards.reload
    assert_not_equal start_size, adam.boards.size
    assert_equal 2, adam.contacts.size
    adam.boards.each do |b|
      post(:board_options, {:id => b.id, :board => {:dodelete => "yes"}})
      assert_equal 2, adam.contacts.size
    end
    adam.boards.reload
    assert_equal 0, adam.boards.size
  end

	def test_send_notification
    jonas = signin_as(:jonas)
		board = Board.find(2)
    start_size = board.messages.size
		post :send_notification, {:id => '2', :message => "I have updated the board nr6, TEST"}
		board.messages.reload
		assert_equal start_size+1, board.messages.size
	#	assert_response :success
	end
  
  private
  
  def view_options(options = {})
    get :options, options
    assert_response :success 
    assert_template("board/options")
  end
  
  def open_invite_popup(options = {})
    get :invite, options
    assert_response :success 
  end
  
  def send_invite(options = {})
    #get :invite, options
    post :create_invite, {:contacts => { "2" => "2", "3" => "0", "temp_19486302" => "meg@stixy.com" }, :msg => { :text => "this is a test" }}.merge(options)
    assert_equal 2, users(:jonas).contacts.count
    assert_not_nil users(:jonas).contacts.find(:first, :conditions => "id = 2 AND status = #{Status::ACTIVE}")
    assert_not_nil users(:jonas).contacts.find(:first, :conditions => "login = 'meg@stixy.com' AND status = #{Status::PENDING}")
  end
  
  
  # This should be an integration test, but since file upload in integration tests is broken, I has to do it like this instead
  # See bug ticket #4635. http://dev.rubyonrails.org/ticket/4635
  #def test_a_file_upload
  #  LibraryPhoto.delete_all
  #  board_controller = @controller
  #  @controller = PublicController.new
  #  post :signin, :user => { :login => users(:jonas).login, :pwd => "password" }
  #  assert_not_nil(session[:user_id])
  #  user = User.find(session[:user_id])
  #  assert_equal users(:jonas).email, user.email
  #  @controller = board_controller
  #  get :show, { :id => 1 } 
  #  @controller = Widgets::PhotoController.new
  #  session[:session_key] = "311331"
  #  post(:upload_photo, {:photo => {:photo => fixture_file_upload('files/camilla.jpg', 'image/jpeg')}})
  #  assert_equal 2, LibraryPhoto.count
  #  @controller = board_controller
  #end
end
