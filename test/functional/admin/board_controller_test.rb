require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/board_controller'

# Re-raise errors caught by the controller.
class Admin::BoardController; def rescue_action(e) raise e end; end

class Admin::BoardControllerTest < Test::Unit::TestCase
  fixtures :boards

  def setup
    @controller = Admin::BoardController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_truth
    assert true
  end
  
#  def test_index
#    get :index
#    assert_response :success
#    assert_template 'list'
#  end
#
#  def test_list
#    get :list
#
#    assert_response :success
#    assert_template 'list'
#
#    assert_not_nil assigns(:boards)
#  end
#
#  def test_show
#    get :show, :id => 1
#
#    assert_response :success
#    assert_template 'show'
#
#    assert_not_nil assigns(:board)
#    assert assigns(:board).valid?
#  end
#
#  def test_new
#    get :new
#
#    assert_response :success
#    assert_template 'new'
#
#    assert_not_nil assigns(:board)
#  end
#
#  def test_create
#    num_boards = Board.count
#
#    post :create, :board => {}
#
#    assert_response :redirect
#    assert_redirected_to :action => 'list'
#
#    assert_equal num_boards + 1, Board.count
#  end
#
#  def test_edit
#    get :edit, :id => 1
#
#    assert_response :success
#    assert_template 'edit'
#
#    assert_not_nil assigns(:board)
#    assert assigns(:board).valid?
#  end
#
#  def test_update
#    post :update, :id => 1
#    assert_response :redirect
#    assert_redirected_to :action => 'show', :id => 1
#  end
#
#  def test_destroy
#    assert_not_nil Board.find(1)
#
#    post :destroy, :id => 1
#    assert_response :redirect
#    assert_redirected_to :action => 'list'
#
#    assert_raise(ActiveRecord::RecordNotFound) {
#      Board.find(1)
#    }
#  end
end
