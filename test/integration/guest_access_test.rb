require "#{File.dirname(__FILE__)}/../test_helper"

class GuestAccessTest < ActionController::IntegrationTest
  fixtures :boards, :boardusers, :abstract_files, :widgets, :users, :roles, :roles_users, :taggings, :tags
  def test_guest_access
    # Cilla, an anonomus user, comes to Stixy and tries to access user restricted pages
    cilla = new_session_as
    cilla.assert_nil(cilla.session[:user_id])
    #cilla.get "/setting/index?popup=true"
    #cilla.is_redirected_to "public/signin"
    #cilla.get "/board/#{boards(:first).id}/"
    #cilla.is_redirected_to "public/signin"
    
    # Jonas logges in and sets up board 1 with guest access privileges
    jonas = new_session_as :jonas
    jonas.get "/board/options/#{boards(:first).id}", :popup => true
    jonas.assert_equal(0, boards(:first).visible)
    jonas.post "/board/board_options", { :id => boards(:first).id, :board => {:visible => 1} }
    boards(:first).reload
    jonas.assert_equal(1, boards(:first).visible)
    
    # Cilla navigates to Board 1 as a guest
    cilla.get "/guest/#{boards(:first).id}"
    cilla.assert_equal(200, cilla.status)
    
    #Jonas changes privilages so guest can edit, but the guest needs a password
    jonas.post "/board/board_options", { :id => boards(:first).id, :board => {:editable => 1, :pwd_protected => 1, :pwd => "test"}}
    boards(:first).reload
    jonas.assert_equal(1, boards(:first).editable)
    jonas.assert_equal(1, boards(:first).pwd_protected)
    jonas.assert_equal("test", boards(:first).pwd)
    
    # Cilla navigates to Board 1 as a guest
    cilla.get "/guest/#{boards(:first).id}"
    cilla.assert_equal(302, cilla.status)
    cilla.follow_redirect!
    cilla.assert_template "guest/password"
    cilla.post "/guest/password", { :id => boards(:first).id, :password =>  "test"}
    cilla.assert(cilla.session[:guest].include?(boards(:first).id.to_s), "Not included")
    cilla.assert_equal(302, cilla.status)
    cilla.follow_redirect!
    cilla.assert_template "guest/edit"
    
    #This doesn't work while everything is redercted to public/signin
     # Cilla signs-up for Stixy and tries to access Stixyboard 1. Should fail.
     cilla.post "/public/signup", { :user => { :pwd => "testar", :pwd_confirmation => "testar", :login => "cilla@hugeinc.com", :terms_of_service => 1}, :popup => true}
     cilla.assert_equal(200, cilla.status)
    
     #cilla.get "/board/#{boards(:first).id}"
     #cilla.assert_equal(302, cilla.status)
     #cilla.follow_redirect!
     #cilla.assert_template "board/overview"
    
    upload_id = "temp_1234"
    # Jonas adds photo widget to gust stixyboard and uploads a photo
    fake_upload abstract_files(:image_home_page), upload_id, jonas.session[:session_key]    
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&photo_id=#{abstract_files(:image_home_page).id}&upload_id=#{upload_id}&session_id=#{jonas.session[:session_key]}&width=300&height=200&filter=0&rotation=0"
    #jonas.assert_equal(4, jonas.response.headers['Status-Text'])
    jonas.update_widget({"board_#{boards(:first).id}" => {:temp_1 => {:widget_id => 2, :top => 200, :left => 200}}})
    new_widget = WidgetPhoto.find(jonas.assigns(:boards)[0][1][0][1])
    jonas.update_widget({"board_#{boards(:first).id}" => {new_widget.id => {:widget_id => 2, :photo => {:photo_id => abstract_files(:image_home_page).id} }}})
    # resize photo
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&widget_id=#{new_widget.id}&photo_id=#{abstract_files(:image_home_page).id}&width=400&height=300&filter=0&rotation=0"
    #jonas.assert_equal(2, jonas.response.headers['Status-Text'])
    # reload page
    jonas.get "/board/#{boards(:first).id}"
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&widget_id=#{new_widget.id}&photo_id=#{abstract_files(:image_home_page).id}&width=400&height=300&filter=0&rotation=0"
    #jonas.assert_equal(1, jonas.response.headers['Status-Text'])
    
    
    # Cilla plays around with the new photo widget (Cilla is now logged in, but not a member of the board)
#    cilla.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&widget_id=#{new_widget.id}&photo_id=#{library_photos(:version_2).id}&width=300&height=200&filter=1&rotation=90"
#    cilla.assert_equal(2, cilla.response.headers['Status-Text'])
#    cilla.update_widget({new_widget.id => {:widget_id => 2, :base => {:left => 200, :top => 500}}})
#    new_widget.reload
#    assert_equal(200, new_widget.left)
#    assert_equal(500, new_widget.top)
    # reload page
#    cilla.get "/board/#{boards(:first).id}"
#    cilla.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&widget_id=#{new_widget.id}&photo_id=#{library_photos(:version_2).id}&width=300&height=200&filter=1&rotation=90"
#    cilla.assert_equal(1, cilla.response.headers['Status-Text'])
    
    # Roine accesses guest stixyboar
    roine = new_session_as
    roine.get "/guest/#{boards(:first).id}"
    roine.follow_redirect!
    roine.post "/guest/password", { :id => boards(:first).id, :password =>  "test"}
    roine.follow_redirect!
    roine.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&widget_id=#{new_widget.id}&photo_id=#{abstract_files(:image_home_page).id}&width=200&height=100&filter=2&rotation=180"
    #roine.assert_equal(2, roine.response.headers['Status-Text'])
    roine.update_widget({"board_#{boards(:first).id}" => {"widget_#{new_widget.id}" => {:widget_id => 2, :left => 300, :top => 400}}})
    new_widget.reload
    assert_equal(300, new_widget.left)
    assert_equal(400, new_widget.top)
    #assert_equal(180, LibraryPhoto.find(new_widget.photos.first.id).rotation)
    
    # Jonas reloads page
    jonas.get "/board/#{boards(:first).id}"
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&widget_id=#{new_widget.id}&photo_id=#{abstract_files(:image_home_page).id}&width=200&height=100&filter=2&rotation=180"
    #jonas.assert_equal(1, jonas.response.headers['Status-Text'])
    
    # Roine adds photo widget to guest stixyboard and uploads a photo
    fake_upload abstract_files(:image_home_page), upload_id, roine.session[:session_key]    
    roine.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&photo_id=#{abstract_files(:image_home_page).id}&upload_id=#{upload_id}&session_id=#{roine.session[:session_key]}&width=300&height=200&filter=0&rotation=0"
    #roine.assert_equal(4, roine.response.headers['Status-Text'])
    roine.update_widget({"board_#{boards(:first).id}" => {:temp_1 => {:widget_id => 2, :top => 200, :left => 200}}})
    guest_widget = WidgetPhoto.find(roine.assigns(:boards)[0][1][0][1])
    roine.update_widget({"board_#{boards(:first).id}" => {guest_widget.id => {:widget_id => 2, :photo => {:photo_id => abstract_files(:image_home_page).id} }}})
    
    # Jonas reloads page
    jonas.get "/board/#{boards(:first).id}"
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&widget_id=#{guest_widget.id}&photo_id=#{abstract_files(:image_home_page).id}&width=200&height=100&filter=2&rotation=180"
    #jonas.assert_equal(2, jonas.response.headers['Status-Text'])
    jonas.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&widget_id=#{guest_widget.id}&photo_id=#{abstract_files(:image_home_page).id}&width=200&height=100&filter=2&rotation=180"
    #jonas.assert_equal(1, jonas.response.headers['Status-Text'])
    
    # Cilla reloads page
    cilla.get "/board/#{boards(:first).id}"
    cilla.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&widget_id=#{guest_widget.id}&photo_id=#{abstract_files(:image_home_page).id}&width=200&height=100&filter=2&rotation=180"
    #cilla.assert_equal(1, cilla.response.headers['Status-Text'])
    cilla.get "/widgets/photo/photo/camilla.jpg?board_id=#{boards(:first).id}&widget_id=#{guest_widget.id}&photo_id=#{abstract_files(:image_home_page).id}&width=200&height=100&filter=0&rotation=180"
    #cilla.assert_equal(2, cilla.response.headers['Status-Text'])
    
    jonas.end_session
    cilla.end_session
    roine.end_session
  end
  
end
