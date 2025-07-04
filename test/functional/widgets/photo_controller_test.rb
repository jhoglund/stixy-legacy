require File.dirname(__FILE__) + '/../../test_helper'
require 'widgets/default_controller'
require 'widgets/photo_controller'

# Re-raise errors caught by the controller.
class Widgets::PhotoController; def rescue_action(e) raise e end; end

class Widgets::PhotoControllerTest < Test::Unit::TestCase
  fixtures :users, :boards, :boardusers, :roles, :roles_users
  def setup
    @controller = Widgets::PhotoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    ImageFile.destroy_all
  end
  
  def teardown
  end

  def test_a_file_upload
    @request.env['HTTP_ACCEPT'] = 'text/xml'
    assert_equal 0, ImageFile.count
    post(:create, file("test_1.jpg", "150", "150", "270", "1", "temp_333", "123456789"), {:user_id => users(:jonas).id})
    assert_equal 1, ImageFile.count
    image = ImageFile.find(:first)
    assert_equal "test_1.jpg", image.filename
    assert_equal 150, image.width
    assert_equal 150, image.height
    assert_equal 270, image.rotation
    assert_equal 1, image.filter
    assert_equal "temp_333", image.upload_id
    assert_equal "123456789", image.session_id
  end
  
  protected
  
  def file(filename = "test.jpg", width = "50", height = "50", rotation = "90", filter = "2", upload_id = "temp_12345", session_id = "123456")
    f = ImageFile.create(:filename => filename, :width => width, :height => height, :rotation => rotation, :filter => filter, :upload_id => upload_id, :session_id => session_id)
    body = { :photo => f.attributes }
    body[:photo].merge!(:thumbnails => { :t => f.thumb.attributes, :original => f.original.attributes })
    f.destroy
    body
  end
end