require File.dirname(__FILE__) + '/../test_helper'

class BetaTesterTest < Test::Unit::TestCase
  fixtures :beta_testers, :roles, :users

  def test_create_invalid_user
    beta_tester = BetaTester.new
    # Invalid login, not a valid email
    user = User.new(:role_ids => [Role::USER], :pwd => "pwd_temp_beta", :pwd_confirmation => "pwd_temp_beta", :login => "ottoman.stixy.com", :login_confirmation => "ottoman.stixy.com", :status => Status::PENDING)
    assert !user.save
    beta_tester.user = user
    # Save should fail
    assert !beta_tester.save
    # Errors should be raised
    assert_match ErrorMessages::Login::NOT_VALID, user.errors.on(:login)
    # This login is already taken
    user = User.new(:role_ids => [Role::USER], :pwd => "pwd_temp_beta", :pwd_confirmation => "pwd_temp_beta", :login => users(:jonas).login, :login_confirmation => users(:jonas).login, :status => Status::PENDING)
    assert !user.save
    beta_tester.user = user
    # Save should fail
    assert !beta_tester.save    
    # Errors should be raised
    assert_match ErrorMessages::Login::USED, user.errors.on(:login)
  end

  def test_create_valid_user
    beta_tester = BetaTester.new
    beta_tester.user = User.create!(:role_ids => [Role::USER], :pwd => "pwd_temp_beta", :pwd_confirmation => "pwd_temp_beta", :login => "ottoman@stixy.com", :login_confirmation => "ottoman@stixy.com", :status => Status::PENDING)
    beta_tester.comment = "This is a test text"
    assert beta_tester.save!
    assert_equal beta_tester.user.login, "ottoman@stixy.com"
    assert_equal beta_tester.user.email, "ottoman@stixy.com"
    assert_equal beta_tester.user.role_ids, [Role::USER]
    assert_equal beta_tester.user.status, Status::PENDING
    assert_equal beta_tester.comment, "This is a test text"
    
    # Test the relation between beta tester and user
    assert_equal BetaTester.find_by_comment("This is a test text").user.login, "ottoman@stixy.com"
  end

end
