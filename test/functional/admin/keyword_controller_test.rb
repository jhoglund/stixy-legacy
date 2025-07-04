require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/keyword_controller'

# Re-raise errors caught by the controller.
class Admin::KeywordController; def rescue_action(e) raise e end; end

class Admin::KeywordControllerTest < Test::Unit::TestCase
  fixtures :keywords

  def setup
    @controller = Admin::KeywordController.new
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
#    assert_not_nil assigns(:keywords)
#  end
#
#  def test_show
#    get :show, :id => 1
#
#    assert_response :success
#    assert_template 'show'
#
#    assert_not_nil assigns(:keyword)
#    assert assigns(:keyword).valid?
#  end
#
#  def test_new
#    get :new
#
#    assert_response :success
#    assert_template 'new'
#
#    assert_not_nil assigns(:keyword)
#  end
#
#  def test_create
#    num_keywords = Keyword.count
#
#    post :create, :keyword => {}
#
#    assert_response :redirect
#    assert_redirected_to :action => 'list'
#
#    assert_equal num_keywords + 1, Keyword.count
#  end
#
#  def test_edit
#    get :edit, :id => 1
#
#    assert_response :success
#    assert_template 'edit'
#
#    assert_not_nil assigns(:keyword)
#    assert assigns(:keyword).valid?
#  end
#
#  def test_update
#    post :update, :id => 1
#    assert_response :redirect
#    assert_redirected_to :action => 'show', :id => 1
#  end
#
#  def test_destroy
#    assert_not_nil Keyword.find(1)
#
#    post :destroy, :id => 1
#    assert_response :redirect
#    assert_redirected_to :action => 'list'
#
#    assert_raise(ActiveRecord::RecordNotFound) {
#      Keyword.find(1)
#    }
#  end
end
