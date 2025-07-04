#!/usr/bin/env ruby

require "#{File.dirname(__FILE__)}/../test_helper"


class BoardWidgetsTest < ActionController::IntegrationTest
  fixtures :users, :boards, :boardusers, :library_photos, :library_documents, :widget_instances, :library_photos_widget_instances, :widgets, :roles, :roles_users
  
  def setup
  end
  
  def teardown
    ImageFile.destroy_all
  end
  
  
  def xtest_photo_widget
    
    #fake_upload LibraryPhoto.find(2), upload_id, jonas.session[:session_key]
    
    jonas = new_session_as :jonas
    jonas.assert_not_nil(jonas.session[:user_id])
    upload_id = "2223344"
    
    jonas.get "/setting/index/"
    jonas.get "/board/1/"
    jonas.assert_equal 0, ImageFile.count
    file = upload_file :filename => '/files/camilla.jpg'
    jonas.assert_equal file.content_type, "image/jpeg"
    jonas.post("/widgets/photo/upload_photo", {:photo => {:photo => file}, :id => "temp_12345"}, {:user_id => users(:jonas).id, :board_id => boards(:first).id})
    jonas.assert_equal 1, ImageFile.count
    
    # Accessing a photo that doesn't exist
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=1&photo_id=22&upload_id=#{upload_id}&session_id=#{jonas.session[:session_key]}&width=300&height=200&filter=0&rotation=0"
    jonas.assert_nil(jonas.response.headers['Status-Text'])
    
    
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=1&photo_id=2&upload_id=#{upload_id}&session_id=#{jonas.session[:session_key]}&width=300&height=200&filter=0&rotation=0"
    jonas.assert_nil(4, jonas.response.headers['Status-Text'])
    
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=1&photo_id=2&upload_id=#{upload_id}&session_id=#{jonas.session[:session_key]}&width=300&height=200&filter=0&rotation=0"
    jonas.assert_equal(3, jonas.response.headers['Status-Text'])
    
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=1&photo_id=2&upload_id=#{upload_id}&session_id=#{jonas.session[:session_key]}&width=200&height=200&filter=0&rotation=0"
    jonas.assert_equal(4, jonas.response.headers['Status-Text'])
    
    jonas.update_widget({:board_1 => {:temp_1 => {:widget_id => 2, :top => 200, :left => 200}}})
    
    jonas.assert_select("new_id", jonas.assigns(:boards)[0][1][0][1].to_s)
    jonas.assert_select("old_id", "temp_1")
    new_widget = WidgetPhoto.find(jonas.assigns(:boards)[0][1][0][1].to_s)
    
    jonas.update_widget({:board_1 => {new_widget.id => {:widget_id => 2, :photo => {:photo_id => 2} }}})
    
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=1&widget_id=#{new_widget.id}&photo_id=2&upload_id=#{upload_id}&session_id=#{jonas.session[:session_key]}&width=200&height=200&filter=0&rotation=0"
    #jonas.assert_equal(1, jonas.response.headers['Status-Text'])
    jonas.assert_not_nil(new_widget.photos.find(:first))
    
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=1&widget_id=#{new_widget.id}&photo_id=2&width=200&height=200&filter=2&rotation=0"
    #jonas.assert_equal(2, jonas.response.headers['Status-Text'])
    jonas.assert_not_nil(new_widget.photos.find(:first))
    
    adam = new_session_as :adam
    adam.assert_not_equal(adam.session[:session_key], jonas.session[:session_key])
    adam.get "/widgets/photo/photo/camilla.jpg?board_id=1&widget_id=#{new_widget.id}&photo_id=2&width=200&height=200&filter=2&rotation=0"
    #adam.assert_equal(1, adam.response.headers['Status-Text'])
    adam.assert_not_nil(new_widget.photos.find(:first))
    
    adam.get "/widgets/photo/photo/camilla.jpg?board_id=1&widget_id=#{new_widget.id}&photo_id=2&width=200&height=200&filter=0&rotation=0"
    #adam.assert_equal(2, adam.response.headers['Status-Text'])
    adam.assert_not_nil(new_widget.photos.find(:first))
    
    old_session_id = jonas.session[:session_key]
    jonas.signout
    jonas.assert_nil(jonas.session[:user_id])
    jonas.assert_equal(old_session_id, jonas.session[:session_key])
    jonas.end_session
    jonas = new_session_as :jonas
    jonas.assert_not_equal(old_session_id, jonas.session[:session_key])
    
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=1&widget_id=#{new_widget.id}&photo_id=2&width=300&height=300&filter=2&rotation=0"
    #jonas.assert_equal(2, jonas.response.headers['Status-Text'])
    jonas.assert_not_nil(new_widget.photos.find(:first))
    
    jonas.assert_not_equal(adam.session[:session_key], jonas.session[:session_key])
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=1&widget_id=#{new_widget.id}&photo_id=2&width=300&height=300&filter=2&rotation=0"
    #jonas.assert_equal(1, jonas.response.headers['Status-Text'])
    jonas.assert_not_nil(new_widget.photos.find(:first))    
    
    # This board is public and NOT password protected
    # Jonas should be able to access the photo
    # The photo will be recreated since the version is not compatible to the param string
    jonas.get("/widgets/photo/photo/camilla.jpg?board_id=2&widget_id=4&photo_id=4&width=300&height=300&filter=2&rotation=0")
    jonas.assert_equal 2, jonas.assigns(:status)
    
    # This board is public BUT it is also password protected
    # Jonas is NOT authorized to this board and should NOT be able to access the photo
    jonas.get("/widgets/photo/photo/camilla.jpg?board_id=4&widget_id=5&photo_id=6&width=300&height=300&filter=2&rotation=0")
    jonas.assert_equal 5, jonas.assigns(:status)
    
    # This board is public BUT it is also password protected (same as above)
    # Jonas first gets access to the board by providing the right password, and now should have access to the photo
    jonas.post("/guest/password/4", {:password => "test"})
    jonas.assert_not_nil(jonas.session[:guest].include?(4.to_s))
    jonas.follow_redirect!
    jonas.assert_response :success
    jonas.assert_template "guest/edit"
    jonas.get("/widgets/photo/photo/camilla.jpg?board_id=4&widget_id=5&photo_id=6&width=300&height=300&filter=2&rotation=0")
    jonas.assert_equal 2, jonas.assigns(:status)
    
    maria = new_session
    #Same as above but now as an annonemus user
    
    # This board is public and NOT password protected
    # Maria should be able to access the photo
    # The photo is now compatible to the param string and therefor doesn't have to be recreated
    maria.get("/widgets/photo/photo/camilla.jpg?board_id=2&widget_id=4&photo_id=4&width=300&height=300&filter=2&rotation=0")
    maria.assert_equal 1, maria.assigns(:status)
    
    # This board is public BUT it is also password protected
    # Maria is NOT authorized to this board and should NOT be able to access the photo
    maria.get("/widgets/photo/photo/camilla.jpg?board_id=4&widget_id=5&photo_id=6&width=300&height=300&filter=2&rotation=0")
    maria.assert_equal 5, maria.assigns(:status)
    
    # This board is public BUT it is also password protected (same as above)
    # Maria first gets access to the board by providing the right password, and now should have access to the photo
    maria.post("/guest/password/4", {:password => "test"})
    maria.assert_not_nil(maria.session[:guest].include?(4.to_s))
    maria.follow_redirect!
    maria.assert_response :success
    maria.assert_template "guest/edit"
    maria.get("/widgets/photo/photo/camilla.jpg?board_id=4&widget_id=5&photo_id=6&width=300&height=300&filter=2&rotation=0")
    maria.assert_equal 1, maria.assigns(:status)
   
    jonas.end_session
    maria.end_session
    adam.end_session
  end
#  
#  def test_document_widget
#    jonas = new_session_as :jonas
#    jonas.assert_not_nil(jonas.session[:user_id])
#    
#    upload_id = "2223344"
#    
#    fake_upload LibraryDocument.find(1), upload_id, jonas.session[:session_key]
#    
#    jonas.get "/widgets/document/file/camilla.jpg?board_id=1&file_id=1&upload_id=#{upload_id}&session_id=#{jonas.session[:session_key]}"
#    jonas.assert_equal(2, jonas.response.headers['Status-Text'])
#        
#    jonas.update_widget({:board_1 => {:temp_1 => {:widget_id => 3, :top => 200, :left => 200, :document => {:document_id => 1}}}})
#    
#    jonas.assert_select("new_id", jonas.assigns(:boards)[0][1][0][1].to_s)
#    jonas.assert_select("old_id", "temp_1")
#    new_widget = WidgetDocument.find(jonas.assigns(:boards)[0][1][0][1].to_s)
#    jonas.assert_not_nil(new_widget.documents.find(:first))
#    
#    jonas.get "/widgets/document/file/camilla.jpg?board_id=1&widget_id=#{new_widget.id}&file_id=1&upload_id=#{upload_id}&session_id=#{jonas.session[:session_key]}"
#    jonas.assert_equal(1, jonas.response.headers['Status-Text'])
#    jonas.assert_equal 200, jonas.status
#    
#    adam = new_session_as :adam
#    adam.assert_not_equal(adam.session[:session_key], jonas.session[:session_key])
#    adam.get "/widgets/document/file/camilla.jpg?board_id=1&widget_id=#{new_widget.id}&file_id=1"
#    adam.assert_equal(1, adam.response.headers['Status-Text'])
#    adam.assert_equal 200, adam.status
#    
#    
#    jonas.signout
#    jonas.end_session
#    jonas = new_session_as :jonas
#    
#    jonas.get "/widgets/document/file/camilla.jpg?board_id=1&widget_id=#{new_widget.id}&file_id=1"
#    jonas.assert_equal(1, jonas.response.headers['Status-Text'])
#    jonas.assert_equal 200, adam.status
#    jonas.end_session
#    adam.end_session
#  end
# 
#  def test_photo_widget_anonomus_user_on_example_board
#    anonomus = new_session_as
#    user = anonomus.assigns(:user)
#    anonomus.assert_nil(anonomus.session[:user_id])
#    anonomus.assert_equal(1, user.id)
#    anonomus.assert_equal(Board, user.boards.find(:first).class)
#    upload_id = "2223344"
#
#    # Testing one of the example boards
#    # Uploading the photo
#    fake_upload LibraryPhoto.find(6), upload_id, anonomus.session[:session_key]
#
#    # Viewing the photo
#    anonomus.get "/widgets/photo/photo/camilla.jpg?board_id=5&photo_id=6&upload_id=#{upload_id}&session_id=#{anonomus.session[:session_key]}&width=300&height=200&filter=0&rotation=0"
#    anonomus.assert_equal(4, anonomus.response.headers['Status-Text'])
#   
#    # Testing a new board, without an ID (id 0)
#    # Uploading the photo
#    fake_upload LibraryPhoto.find(6), upload_id, anonomus.session[:session_key]
#
#    # Viewing the photo
#    anonomus.get "/widgets/photo/photo/camilla.jpg?board_id=0&photo_id=6&upload_id=#{upload_id}&session_id=#{anonomus.session[:session_key]}&width=300&height=200&filter=0&rotation=0"
#    anonomus.assert_equal(4, anonomus.response.headers['Status-Text'])
#    
#    anonomus.end_session
#  end
#
#  def test_new_board_and_note_widget
#    jonas = new_session_as :jonas
#    jonas.assert_not_nil(jonas.session[:user_id])
#    
#    # First, add a new widget to an existing board and see so no board id is returned to the browser
#    jonas.update_widget({:board_1 => {:temp_1 => {:widget_id => 1, :top => 200, :left => 200, :text => {:value => "This is text"}}}})
#    
#    jonas.assert_select("new_id", jonas.assigns(:boards)[0][1][0][1].to_s)
#    jonas.assert_select("old_id", "temp_1")
#    
#    new_widget = WidgetNote.find(jonas.assigns(:boards)[0][1][0][1])
#    jonas.assert_equal("This is text", new_widget.content)
#    jonas.end_session
#       
#    jonas.end_session
#  end
#  
#  
#  
#  def test_note_widget
#    jonas = new_session_as :jonas
#    jonas.assert_not_nil(jonas.session[:user_id])
#    
#    jonas.update_widget({:board_1 => {:temp_1 => {:widget_id => 1, :top => 200, :left => 200, :text => {:value => "This is text"}}}})
#    
#    jonas.assert_select("new_id", jonas.assigns(:boards)[0][1][0][1].to_s)
#    jonas.assert_select("old_id", "temp_1")
#    new_widget = WidgetNote.find(jonas.assigns(:boards)[0][1][0][1])
#    jonas.assert_equal("This is text", new_widget.content)
#    
#    jonas.end_session
#  end
#  
#  def test_multiple_boards_and_widgets
#    jonas = new_session_as :jonas
#    jonas.assert_not_nil(jonas.session[:user_id])
#    
#    jonas.update_widget({
#      :board_1 => {
#        :temp_1 => {:widget_id => 1, :top => 200, :left => 200, :text => {:value => "This is text board 1"}},
#        :temp_2 => {:widget_id => 1, :top => 200, :left => 200, :text => {:value => "This is text board 1, w 2"}}
#      },
#      :board_2 => {:temp_1 => {:widget_id => 1, :top => 100, :left => 100, :text => {:value => "This is text board 2"}}}
#    })
#    
#    jonas.assert_select("board_1 > widget:first-of-type > new_id", jonas.assigns(:boards)[0][1][0][1].to_s)
#    jonas.assert_select("board_1 > widget:last-of-type > new_id", jonas.assigns(:boards)[0][1][1][1].to_s)
#    jonas.assert_select("board_2 > widget > new_id", jonas.assigns(:boards)[1][1][0][1].to_s)
#
#    new_widget_1 = WidgetNote.find(jonas.assigns(:boards)[0][1][0][1].to_s)
#    new_widget_2 = WidgetNote.find(jonas.assigns(:boards)[0][1][1][1].to_s)
#    jonas.assert_equal("This is text board 1, w 2", new_widget_1.content)
#    jonas.assert_equal("This is text board 1", new_widget_2.content)
#    
#    jonas.end_session
#  end
#  
#  def test_todo_widget
#    jonas = new_session_as :jonas
#    jonas.assert_not_nil(jonas.session[:user_id])
#    
#    todo_body = { :board_1 => { :temp_1 => {
#      :widget_id => 4,
#      :top => "108",
#      :left => "275",
#      :width => "230",
#      :height => "200",
#      :time => "December 19 2006 12:00 PM UTC",
#      :text => { :value => "Test text" },
#      :reminder => {
#        :remind_at => "1.00",
#        :remind_users => { "0" => "0", "2" => "1", "3" => "1", "4" => "0", "5" => "0" }
#      }
#    }}}
#    jonas.update_widget(todo_body)
#    
#    jonas.assert_select("new_id", jonas.assigns(:boards)[0][1][0][1].to_s)
#    jonas.assert_select("old_id", "temp_1")
#    new_widget = WidgetTodo.find(jonas.assigns(:boards)[0][1][0][1])
#    jonas.assert_equal("Test text", new_widget.comment)
#    jonas.assert_equal(230, new_widget.width)
#    jonas.assert_equal(200, new_widget.height)
#    jonas.assert_equal(108, new_widget.top)
#    jonas.assert_equal(275, new_widget.left)
#    
#    jonas.assert_equal(Time.parse("December 19 2006 11:00 AM UTC"), new_widget.time)
#    jonas.assert_equal(2, UserNotification.find(:all, :conditions => ["widget_instance_id = ? and time = ?",new_widget.id, Time.parse("December 19 2006 10:00:00")]).size)
#    jonas.assert_not_nil(UserNotification.find(:first, :conditions => ["user_id = ? and widget_instance_id = ? and time = ?", users(:jonas).id, new_widget.id, Time.parse("December 19 2006 10:00:00")]))
#    jonas.assert_not_nil(UserNotification.find(:first, :conditions => ["user_id = ? and widget_instance_id = ? and time = ?", users(:adam).id, new_widget.id, Time.parse("December 19 2006 10:00:00")]))
#    
#    adam = new_session_as :adam
#    todo_body = { :board_1 => { new_widget.id => {
#      :widget_id => 4,
#      :top => "100",
#      :left => "200",
#      :width => "300",
#      :height => "400",
#      :time => "January 29 2007 11:45 AM UTC",
#      :text => { :value => "Test text again" },
#      :reminder => {
#        :remind_at => "2.00",
#        :remind_users => { "0" => "1", "2" => "1", "3" => "1", "4" => "0", "5" => "0" }
#      }
#    }}}
#    adam.update_widget(todo_body)
#    new_widget.reload
#    adam.assert_equal("Test text again", new_widget.comment)
#    adam.assert_equal(100, new_widget.top)
#    adam.assert_equal(200, new_widget.left)
#    adam.assert_equal(300, new_widget.width)
#    adam.assert_equal(400, new_widget.height)
#    
#    adam.assert_equal(Time.parse("January 29 2007 07:45 PM UTC"), new_widget.time)
#    adam.assert_equal(3, UserNotification.find(:all, :conditions => ["widget_instance_id = ? and time = ?",new_widget.id, Time.parse("January 29 2007 17:45:00")]).size)
#    adam.assert_not_nil(UserNotification.find(:first, :conditions => ["user_id = ? and widget_instance_id = ? and time = ?", users(:jonas).id, new_widget.id, Time.parse("January 29 2007 17:45:00")]))
#    adam.assert_not_nil(UserNotification.find(:first, :conditions => ["user_id = ? and widget_instance_id = ? and time = ?", users(:adam).id, new_widget.id, Time.parse("January 29 2007 17:45:00")]))
#    adam.assert_not_nil(UserNotification.find(:first, :conditions => ["user_id = ? and widget_instance_id = ? and time = ?", 0, new_widget.id, Time.parse("January 29 2007 17:45:00")]))
#    
#    todo_body = { :board_1 => { new_widget.id => {
#      :widget_id => 4,
#      :reminder => {
#        :remind_at => "2.00",
#        :remind_users => { "0" => "0", "2" => "1", "3" => "0", "4" => "0", "5" => "0" }
#      }
#    }}}
#    adam.update_widget(todo_body)
#    adam.assert_equal(1, UserNotification.find(:all, :conditions => ["widget_instance_id = ? and time = ?",new_widget.id, Time.parse("January 29 2007 17:45:00")]).size)
#    adam.assert_not_nil(UserNotification.find(:first, :conditions => ["user_id = ? and widget_instance_id = ? and time = ?", users(:jonas).id, new_widget.id, Time.parse("January 29 2007 17:45:00")]))
#    
#    jonas.end_session
#    adam.end_session
#  end

protected
def upload_file(options = {})
  use_temp_file options[:filename] do |file|
    att = ImageFile.create :uploaded_data => fixture_file_upload(file, options[:content_type] || 'image/jpg')
  end
end

def use_temp_file(fixture_filename)
  temp_path = File.join('/tmp', File.basename(fixture_filename))
  FileUtils.mkdir_p File.join(fixture_path, 'tmp')
  FileUtils.cp File.join(fixture_path, fixture_filename), File.join(fixture_path, temp_path)
  yield temp_path
ensure
  FileUtils.rm_rf File.join(fixture_path, 'tmp')
end


end
