require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/invite_controller'

# Re-raise errors caught by the controller.
class Admin::InviteController; def rescue_action(e) raise e end; end

class Admin::InviteControllerTest < Test::Unit::TestCase
  fixtures :invites

  def setup
    @controller = Admin::InviteController.new
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
#    assert_not_nil assigns(:invites)
#  end
#
#  def test_show
#    get :show, :id => 1
#
#    assert_response :success
#    assert_template 'show'
#
#    assert_not_nil assigns(:invite)
#    assert assigns(:invite).valid?
#  end
#
#  def test_new
#    get :new
#
#    assert_response :success
#    assert_template 'new'
#
#    assert_not_nil assigns(:invite)
#  end
#
#  def test_create
#    num_invites = Invite.count
#
#    post :create, :invite => {}
#
#    assert_response :redirect
#    assert_redirected_to :action => 'list'
#
#    assert_equal num_invites + 1, Invite.count
#  end
#
#  def test_edit
#    get :edit, :id => 1
#
#    assert_response :success
#    assert_template 'edit'
#
#    assert_not_nil assigns(:invite)
#    assert assigns(:invite).valid?
#  end
#
#  def test_update
#    post :update, :id => 1
#    assert_response :redirect
#    assert_redirected_to :action => 'show', :id => 1
#  end
#
#  def test_destroy
#    assert_not_nil Invite.find(1)
#
#    post :destroy, :id => 1
#    assert_response :redirect
#    assert_redirected_to :action => 'list'
#
#    assert_raise(ActiveRecord::RecordNotFound) {
#      Invite.find(1)
#    }
#  end
end
