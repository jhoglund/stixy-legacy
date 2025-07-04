require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  include AuthenticatedTestHelper
  
  fixtures :users, :roles
  
  def setup
    @user = User.find(users(:jonas).id)
  end
  
  def teardown
    @user.pwd = nil
    @user.login = nil
    @user.pwd_confirmation = nil
    @user.login_confirmation = nil
  end

  def test_user
    assert_kind_of User, @user
    assert_equal users(:jonas).id, @user.id
    assert_equal users(:jonas).login, @user.login
    assert_equal users(:jonas).email, @user.email
    assert_equal users(:jonas).pwd, @user.pwd
    assert_equal users(:jonas).nick_name, @user.nick_name
    assert_equal users(:jonas).first_name, @user.first_name
    assert_equal users(:jonas).last_name, @user.last_name
    assert_equal users(:jonas).description, @user.description
    assert_equal users(:jonas).last_login_date, @user.last_login_date
    assert_equal users(:jonas).created_on, @user.created_on
    assert_equal users(:jonas).updated_on, @user.updated_on
    assert_equal users(:jonas).created_by_id, @user.created_by_id
    assert_equal users(:jonas).updated_by_id, @user.updated_by_id
    assert_equal users(:jonas).status, @user.status
    assert_equal users(:jonas).city, @user.city
    assert_equal users(:jonas).country, @user.country
    assert_equal users(:jonas).mobile_phone, @user.mobile_phone
    assert_equal users(:jonas).pref_enable_grag_drop, @user.pref_enable_grag_drop
    assert_equal users(:jonas).pref_send_email_and_mobile, @user.pref_send_email_and_mobile
    assert_equal users(:jonas).pref_photo_auto_upload, @user.pref_photo_auto_upload
    assert_equal users(:jonas).time_offset, @user.time_offset
    assert_equal users(:jonas).daylight_savings, @user.daylight_savings
  end
  
  def test_create_invalid_user
    user = User.new
    
    # Invalid login, not a valid email
    user.login = "dsd.dsd"
    
    # Invalid login confirm, not a valid email
    user.login_confirmation = "dsd.dsd"
    
    # To short password
    user.pwd = "sdf"
    
    # Confirmation doesn't match password
    user.pwd_confirmation = "sf"
    
    # Terms of use is not checked
    user.terms_of_service = "0"
    
    # Save should fail
    assert !user.save
    
    # Errors should be raised
    assert_match ErrorMessages::Login::NOT_VALID, user.errors.on(:login)
    assert_equal [ErrorMessages::Password::MISSMATCH, ErrorMessages::Password::TOO_SHORT], user.errors.on(:pwd)
    assert_match ErrorMessages::Misc::TERMS_OF_SERVICE, user.errors.on(:terms_of_service)
    assert_match ErrorMessages::Misc::BLANK_ROLE, user.errors.on(:roles)
    
    # This login is already taken
    user.login = users(:jonas).login
    # This login is already taken
    user.login_confirmation = users(:jonas).login
    
    # Password is too long
    user.pwd = "sdfgrefsdtwgdfsreg12dsdsdsdsdsdsdsdsd3456789234hjddhfhd"
    
    # Save should fail
    assert !user.save    
    
    # Errors should be raised
    assert_match ErrorMessages::Login::USED, user.errors.on(:login)
    assert_equal [ErrorMessages::Password::MISSMATCH, ErrorMessages::Password::TOO_LONG], user.errors.on(:pwd)
    
    user = User.new
    user.terms_of_service = "1"
    user.pwd = "password"
    user.pwd_confirmation = "passwor"
    user.save
    assert_equal ErrorMessages::Password::MISSMATCH, user.errors.on(:pwd)
  end
    
  def test_create_valid_user
    user = User.new
    user.login = "ottoman@stixy.com"
    user.login_confirmation = "ottoman@stixy.com"
    user.role_ids = [Role::USER]
    user.pwd = "rightlength"
    user.pwd_confirmation = "rightlength"
    user.terms_of_service = "1"
    assert user.save!
  end
  
  def test_update_invalid_user   
     
    # Invalid login, not a valid email
    @user.login = "dsad"
    
    # Confirmation doesn't match login
    @user.login_confirmation = "ee"
    
    # To short password
    @user.pwd = "ddsa"
    
    # Confirmation doesn't match password
    @user.pwd_confirmation = "ee"
    
    # Save should fail
    assert !@user.save
    
    # Errors should be raised
    assert_equal [ErrorMessages::Login::MISSMATCH, ErrorMessages::Login::NOT_VALID], @user.errors.on(:login)
    assert_equal [ErrorMessages::Password::MISSMATCH, ErrorMessages::Password::TOO_SHORT], @user.errors.on(:pwd)
          
    # Invalid login, email is taken
    @user.login = "maria@stixy.com"
    
    # Confirmation doesn't match login
    @user.login_confirmation = ""

    # To long password
    @user.pwd = "sdfgrefsdtwddsadsadddsadasdasdasdsadjkkfsdfnbdsfjsdhdsfbsdfbsdfjkfdshjfsd"
    
    # Confirmation doesn't match password
    @user.pwd_confirmation = ""
    
    # Save should fail
    assert !@user.save
    
    # Errors should be raised
    assert_equal [ErrorMessages::Login::MISSMATCH, ErrorMessages::Login::USED], @user.errors.on(:login)
    assert_equal [ErrorMessages::Password::MISSMATCH, ErrorMessages::Password::TOO_LONG], @user.errors.on(:pwd)
  end
   
  def test_update_of_pwd_and_login
    @user.pwd = "ssddss"
    @user.pwd_confirmation = "ssddss"
    @user.login = "ssff@sssss.ss"
    @user.login_confirmation = "ssff@sssss.ss"
    @user.save
    assert_nil @user.errors.on(:pwd)
  
    @user.pwd = "ssddss"
    @user.pwd_confirmation = "ssddss"
    @user.login = "jonne@stixy.com"
    @user.login_confirmation = "jonne@stixy.com"
    @user.save
    assert_nil @user.errors.on(:pwd)
  
    @user.pwd = "ssddss"
    @user.pwd_confirmation = "ssddss"
    @user.login = "jonne@stixy.com"
    @user.login_confirmation = "jonne@stixy.com"
    @user.save
    assert_nil @user.errors.on(:pwd)
  
    @user.pwd = "ssddssdd"
    @user.pwd_confirmation = "ssddssdd"
    @user.login = "jonne@stixy.com"
    @user.login_confirmation = "jonne@stixy.com"
    @user.save
    assert_nil @user.errors.on(:pwd)
  end

  def test_do_not_update_of_pwd_and_login   
    # Make shure that login and password is not updated if @user.pwd_update is set to "0"
    # If @user.pwd_update == "0" no validation will be done so we need to stop the pwd and login from being saved
    @user.pwd = "password_not_to_be_changed"
    @user.pwd_confirmation = "password_not_to_be_changed"
    @user.login = "login_to_be_changed@stixy.com"
    @user.login_confirmation = "login_to_be_changed@stixy.com"
    @user.save
    assert_not_equal User.encrypt("newpassword", @user.salt), @user.crypted_password
    assert_equal @user.login, "login_to_be_changed@stixy.com"
  
  end

  def test_update_valid_user
    user = User.find(users(:jonas).id)
    user.login = "jonne@stixy.com"
    user.login_confirmation = "jonne@stixy.com"
    user.pwd = "newpassword"
    user.pwd_confirmation = "newpassword"
    user.first_name = "Jonne"
    user.last_name = "Hogman"
    user.description = "A test of description"
    user.zip = "30000"
    user.city = "Khamn"
    user.country = "Sverige"
    user.address = "Långvägen 10"
    user.time_offset = -7200.0
    user.daylight_savings = 1 
    # Save should succeed
    assert user.save!
    
    # Fetch the user again and check the data
    reloaded_user = User.find(users(:jonas).id)
    
    # Check the data
    assert_equal "jonne@stixy.com", reloaded_user.login
    assert_equal "jonne@stixy.com", reloaded_user.email
    assert_equal  User.encrypt("newpassword", reloaded_user.salt), reloaded_user.crypted_password
    assert_equal  "Jonne", reloaded_user.first_name
    assert_equal  "Hogman", reloaded_user.last_name
    assert_equal  "A test of description", reloaded_user.description
    assert_equal  "30000", reloaded_user.zip
    assert_equal  "Khamn", reloaded_user.city
    assert_equal  "Sverige", reloaded_user.country
    assert_equal  "Långvägen 10", reloaded_user.address
    assert_equal  -7200.0, reloaded_user.time_offset
    assert_equal  1, reloaded_user.daylight_savings
    assert_equal  Time.parse("2006-10-10 09:15:27"), reloaded_user.adjusted_time(Time.parse("2006-10-10 10:15:27")) # Local date with daylight saving
  end
  
  def test_time
    time_now = Time.now
    @user.time_offset = -5*3600
    @user.daylight_savings = 0 
    
    assert @user.save!
    @user.reload
  
    assert_equal  -5*3600, @user.time_offset
    assert_equal  0, @user.daylight_savings
    assert_equal  time_now+(-5*3600), @user.adjusted_time(time_now)
    
    @user.daylight_savings = 1 
    
    assert @user.save
    @user.reload
    
    assert_equal  time_now+((-5*3600)+3600), @user.adjusted_time(time_now)
    assert_equal  time_now+(-5*3600), @user.adjusted_time(time_now, false) # Without daylight saving
    
    assert_equal  time_now, @user.reset_time(time_now+(-5*3600)+3600)
    assert_equal  time_now, @user.reset_time(time_now+(-5*3600), false) # Without daylight saving
  end
  
  def test_flash_upload_state
    assert_equal users(:jonas).pref_disable_flash_upload, 0
    assert_equal users(:maria).pref_disable_flash_upload, 0
    assert_equal users(:adam).pref_disable_flash_upload, 1
  end
  
  # Act as Authenticated tests

  def test_should_create_user
    assert_difference User, :count do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    assert_no_difference User, :count do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    assert_no_difference User, :count do
      u = create_user(:pwd => nil)
      assert u.errors.on(:pwd)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference User, :count do
      u = create_user(:pwd_confirmation => "")
      assert u.errors.on(:pwd)
    end
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:pwd => 'new password', :pwd_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'new password')
  end
  
  def test_should_not_reset_password
    old_password = users(:quentin).crypted_password
    users(:quentin).update_attributes(:pwd => 'new password', :pwd_confirmation => 'new wrong password')
    assert_equal users(:quentin).crypted_password, old_password
  end

  def test_should_not_rehash_password
    users(:quentin).update_attributes(:login => 'quentin2@example.com')
    assert_equal users(:quentin), User.authenticate('quentin2@example.com', 'password')
  end

  def test_should_authenticate_user
    assert_equal users(:quentin), User.authenticate('quentin@example.com', 'password')
  end

  def test_should_set_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  def test_should_unset_remember_token
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end
  
  #  Deactivate account
  
  def test_create_valid_user_where_login_used_and_canceled
    user = User.new
    user.login = "deactivated@example.com"
    user.login_confirmation = "deactivated@example.com"
    user.role_ids = [Role::USER]
    user.pwd = "rightlength"
    user.pwd_confirmation = "rightlength"
    user.terms_of_service = "1"
    assert user.save!
  end
  
  def test_create_valid_user_where_login_used_but_not_canceled
    user = User.new
    user.login = "aaron@example.com"
    user.login_confirmation = "aaron@example.com"
    user.role_ids = [Role::USER]
    user.pwd = "rightlength"
    user.pwd_confirmation = "rightlength"
    user.terms_of_service = "1"
    assert_equal false, user.save
    assert_match ErrorMessages::Login::USED, user.errors.on(:login)
  end

  protected
    def create_user(options = {})
      User.create({ :login => 'quire@example.com', :login_confirmation => 'quire@example.com', :pwd => 'quiretest', :pwd_confirmation => 'quiretest', :role_ids => [Role::USER], :description => "" }.merge(options))
    end
end
