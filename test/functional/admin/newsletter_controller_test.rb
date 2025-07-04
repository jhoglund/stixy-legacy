require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/newsletter_controller'

# Re-raise errors caught by the controller.
class Admin::NewsletterController; def rescue_action(e) raise e end; end

class Admin::NewsletterControllerTest < Test::Unit::TestCase
  fixtures :roles, :roles_users, :users, :newsletters
  def setup
    @controller = Admin::NewsletterController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Email.delete_all
  end
  
  def test_sending_newsletter
    # Needs to be fixed with the new StixyMail
    signin_as(:jonas)
    post :send_newsletter, :id => 1, :to => "users", :range => { :from => users(:jonas).id.to_s, :to => users(:adam).id.to_s }
    assert_equal 2, Email.count
    assert_not_nil Email.find_by_to(users(:jonas).email)
    assert_not_nil Email.find_by_to(users(:adam).email)
    ActionMailer::Base.send_stored
    assert_equal 2, Email.count
    ActionMailer::Base.send_stored(Status::DEACTIVATED)
    assert_equal 0, Email.count
  end
end
