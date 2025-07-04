require File.dirname(__FILE__) + '/../test_helper'
require 'public_controller'

# Re-raise errors caught by the controller.
class PublicController; def rescue_action(e) raise e end; end

class PublicControllerTest < Test::Unit::TestCase
  fixtures :users, :boards, :boardusers, :roles
  fixtures :roles_users
  def setup
    @controller = PublicController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_temp_board
    xhr :get, :index, {:id => 0}
    assert_equal true, session[:temp_board]
    post :signin, :user => { :login => users(:jonas).login, :pwd => "password" }
    assert_nil session[:temp_board]
    assert_equal true, assigns(:board).is_new                                   
  end                                                                           
                                                                                
  def test_signin_valid_user                                                     
    post :signin, :user => { :login => users(:jonas).login, :pwd => "password" }
    assert_not_nil(session[:user_id])
    user = assigns :current_user
    assert_equal users(:jonas).email, user.email
  end                                                                           
                                                                                
  def test_signin_invalid_login                                                 
    post :signin, :user => { :login => "martin@google.com", :pwd => "password" }
    assert_response :success                                                     
    assert_nil(session[:user_id])    
    assert_equal false, assigns(:current_user).authorized?                                      
  end                                                                            
                                                                                 
  def test_signin_invalid_pwd                                                    
    post :signin, :user => { :login => users(:jonas).login, :pwd => "*password" }
    assert_response :success
    assert_nil(session[:user_id])
    assert_equal false, assigns(:current_user).authorized?                                      
  end
  
  def test_signup_and_signin_valid_user
    post :signup, :user => { :login => "ottoman5@stixy.com", :login_confirmation => "ottoman5@stixy.com", :pwd => "password", :pwd_confirmation => "password", :terms_of_service => "1", :time_offset => Time.now.utc_offset }, :popup => true
    assert_template "public/how_stixy_works"
    assert_select "h1", "Welcome to Stixy"
    post :signin, :user => { :login => "ottoman5@stixy.com", :pwd => "password" }, :popup => true    
    assert_not_nil(session[:user_id])
    user = User.find(session[:user_id])
    assert_equal "ottoman5@stixy.com", user.login
    assert_equal User.encrypt("password",user.salt), user.crypted_password
    # This functionality has to be tested in a browser where the javascript should supply the UTC offset from the users machine
    assert_equal Time.now.utc_offset, user.time_offset
    assert_equal assigns(:board).boardusers.size, 1
    assert_equal user.boards.include?(assigns(:board)), true
  end
  
  def test_signup_and_signin_pending_user
    post :signup, :user => { :login => "regina@example.com", :login_confirmation => "regina@example.com", :pwd => "password333", :pwd_confirmation => "password333", :terms_of_service => "1", :time_offset => Time.now.utc_offset }, :popup => true
    assert_template "public/how_stixy_works"
    assert_select "h1", "Welcome to Stixy"
    post :signin, :user => { :login => "regina@example.com", :pwd => "password333" }, :popup => true    
    assert_not_nil(session[:user_id])
    user = User.find(session[:user_id])
    assert_equal "regina@example.com", user.login
    assert_equal User.encrypt("password333",user.salt), user.crypted_password
    # This functionality has to be tested in a browser where the javascript should supply the UTC offset from the users machine
    assert_equal Time.now.utc_offset, user.time_offset
    assert_equal assigns(:board).boardusers.size, 1
    assert_equal user.boards.include?(assigns(:board)), true
  end
  
 
  def test_reset_password
    old_pwd = users(:jonas).crypted_password
    post :forgot_password, :user => { :login => users(:jonas).login}, :popup => true
    assert_response :success
    users(:jonas).reload
    assert_not_equal(users(:jonas).crypted_password, old_pwd)
    assert_template "forgot_password"
  end
  
  def test_signup_for_beta
    # Changed o beta signup is routed to signup
    
    # assert_template "beta_signup"
    # assert_select "div.left-column", 1
    # post :beta_signup, :beta_tester => { :login => "otto", :time_offset => Time.now.utc_offset, :comment => "test" }
    # assert_select "div.inline-message-error", 1
    # post :beta_signup, :beta_tester => { :login => "ottoman4@stixy.com", :time_offset => Time.now.utc_offset, :comment => "test 2" }
    #assert_select "div.full-column", 1
  end
  
  #def test_sample_no_page
  #  # Gets a sample page that doesn't exist
  #  get :sample, :id => 100
  #  assert_response :missing
  #end
  
end
