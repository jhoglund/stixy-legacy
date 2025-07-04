require File.dirname(__FILE__) + '/../../test_helper'
require 'widgets/todo_controller'

# Re-raise errors caught by the controller.
class Widgets::TodoController; def rescue_action(e) raise e end; end

class Widgets::TodoControllerTest < Test::Unit::TestCase
  fixtures :users, :boards, :boardusers, :roles, :roles_users
  def setup
    @controller = Widgets::TodoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
