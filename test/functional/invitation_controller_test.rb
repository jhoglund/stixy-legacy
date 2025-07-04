require File.dirname(__FILE__) + '/../test_helper'
require 'invitation_controller'

# Re-raise errors caught by the controller.
class InvitationController; def rescue_action(e) raise e end; end

class InvitationControllerTest < Test::Unit::TestCase
  fixtures :users
  def setup
    @controller = InvitationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_me
    assert true
  end
end
