require File.dirname(__FILE__) + '/../../test_helper'
require 'widgets/note_controller'

# Re-raise errors caught by the controller.
class Widgets::NoteController; def rescue_action(e) raise e end; end

class Widgets::NoteControllerTest < Test::Unit::TestCase
  def setup
    @controller = Widgets::NoteController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
