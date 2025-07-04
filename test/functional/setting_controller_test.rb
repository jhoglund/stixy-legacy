require File.dirname(__FILE__) + '/../test_helper'
require 'setting_controller'

# Re-raise errors caught by the controller.
class SettingController; def rescue_action(e) raise e end; end

class SettingControllerTest < Test::Unit::TestCase
  fixtures :users
  def setup
    @controller = SettingController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_go_to_setting
    go_to_settings
  end
  
  def test_password
    jonas = go_to_settings
    post :update, :user => { :pwd => "s", :pwd_confirmation => "" }
    assert_equal ErrorMessages::Password::MISSMATCH, assigns(:current_user).errors.on(:pwd)[0]
    assert_equal ErrorMessages::Password::TOO_SHORT, assigns(:current_user).errors.on(:pwd)[1]
    post :update, :user => { :pwd => "s", :pwd_confirmation => "s"}
    assert_equal ErrorMessages::Password::TOO_SHORT, assigns(:current_user).errors.on(:pwd)
    post :update, :user => { :pwd => "ssssss", :pwd_confirmation => "s"}
    assert_equal ErrorMessages::Password::MISSMATCH, assigns(:current_user).errors.on(:pwd)
    post :update, :user => { :pwd => "12345678910_12345678910_12345678910", :pwd_confirmation => "12345678910_12345678910_12345678910"}
    assert_equal ErrorMessages::Password::TOO_LONG, assigns(:current_user).errors.on(:pwd)
    jonas.reload
    assert_equal User.encrypt("password", assigns(:current_user).salt), assigns(:current_user).crypted_password
    post :update, :user => { :pwd => "new_password", :pwd_confirmation => "new_password"}
    assert_equal 0, assigns(:current_user).errors.size
    jonas.reload
    assert_equal User.encrypt("new_password", assigns(:current_user).salt), assigns(:current_user).crypted_password
    jonas = nil
  end
  
  def test_login
    jonas = go_to_settings
    post :update, :user => { :login => jonas.login, :login_confirmation => "wrong@email.com" }
    assert_equal ErrorMessages::Login::MISSMATCH, assigns(:current_user).errors.on(:login)
    post :update, :user => { :login => "not.valid.email", :login_confirmation => "wrong@email.com" }
    assert_equal ErrorMessages::Login::MISSMATCH, assigns(:current_user).errors.on(:login)[0]
    assert_equal ErrorMessages::Login::NOT_VALID, assigns(:current_user).errors.on(:login)[1]
    post :update, :user => { :login => "valid@email.com", :login_confirmation => "wrong@email.com" }
    assert_equal ErrorMessages::Login::MISSMATCH, assigns(:current_user).errors.on(:login)
    post :update, :user => { :login => "valid@email.com", :login_confirmation => "" }
    assert_equal ErrorMessages::Login::MISSMATCH, assigns(:current_user).errors.on(:login)
    post :update, :user => { :login => "valid@email.com", :login_confirmation => "valid@email.com" }
    assert_equal 0, assigns(:current_user).errors.size
    jonas.reload
    assert_equal "valid@email.com", jonas.login
    jonas = nil
  end
  
  def test_all
    jonas = go_to_settings
    post :update, :user => { 
      :pwd => "new_password", 
      :pwd_confirmation => "new_password",
      :login => "valid@email.com", 
      :login_confirmation => "valid@email.com",
      :first_name => "new_Jonas",
      :last_name => "new_Höglund",
      :description => "new_Proud father of Max and Meg",
      :address => "new_Genvägen 9",
      :city => "new_Karlshamn",
      :zip => "new_37437",
      :country => "new_Sweden",
      :time_offset => 3*3600,
      :daylight_savings => 1,
      :pref_disable_flash_upload => 1
    }
    assert_equal 0, assigns(:current_user).errors.size
    jonas.reload
    assert_equal User.encrypt("new_password", jonas.salt), jonas.crypted_password
    assert_equal jonas.login, "valid@email.com"
    assert_equal jonas.email, "valid@email.com"
    assert_equal jonas.first_name, "new_Jonas"
    assert_equal jonas.last_name, "new_Höglund"
    assert_equal jonas.description, "new_Proud father of Max and Meg"
    assert_equal jonas.address, "new_Genvägen 9"
    assert_equal jonas.city, "new_Karlshamn"
    assert_equal jonas.zip, "new_37437"
    assert_equal jonas.country, "new_Sweden"
    assert_equal jonas.time_offset, 3*3600
    assert_equal jonas.daylight_savings, 1
    assert_equal jonas.pref_disable_flash_upload, 1
    jonas = nil
  end
  

  # Replace this with your real tests.
  def go_to_settings user="jonas"
    jonas = signin_as(user)
    get :index, :popup => true
    assert_response :success
    assert_template "setting/index"
    return jonas
  end
  
end
