require File.dirname(__FILE__) + '/../../test_helper'
require 'widgets/document_controller'

# Re-raise errors caught by the controller.
class Widgets::DocumentController; def rescue_action(e) raise e end; end

class Widgets::DocumentControllerTest < Test::Unit::TestCase
  fixtures :users, :boards, :boardusers, :roles, :roles_users
  def setup
    @controller = Widgets::DocumentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    DocumentFile.destroy_all
  end

  def test_a_file_upload
    @request.env['HTTP_ACCEPT'] = 'text/xml'
    assert_equal 0, DocumentFile.count
    post(:create, file("test_1.doc", "temp_123"), {:user_id => users(:jonas).id})
    assert_equal 1, DocumentFile.count
    doc = DocumentFile.find(:first)
    assert_equal "test_1.doc", doc.filename
    assert_equal "temp_123", doc.upload_id
    assert_equal session[:session_key], doc.session_id
  end
  
  protected
  
  def file(filename = "test.doc", upload_id = "temp_12345")
    f = DocumentFile.create(:filename => filename, :upload_id => upload_id)
    body = { :document => f.attributes }
    f.destroy
    body
  end
end
