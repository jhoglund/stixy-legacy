require File.dirname(__FILE__) + '/../test_helper'
require 'questioner_controller'

# Re-raise errors caught by the controller.
class QuestionerController; def rescue_action(e) raise e end; end

class QuestionerControllerTest < Test::Unit::TestCase
  def setup
    @controller = QuestionerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
