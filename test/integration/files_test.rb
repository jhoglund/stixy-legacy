require "#{File.dirname(__FILE__)}/../test_helper"
require 'rubygems'
require 'mocha'

class FilesTest < ActionController::IntegrationTest
  fixtures :boards, :boardusers, :library_photos_widget_instances, :library_documents_widget_instances, :widgets, :widget_instances, :users, :roles, :roles_users, :abstract_files
  
  def test_a_image_upload
    ImageFileResource.any_instance.stubs(:save).returns(true)
    ImageFile.destroy_all
    jonas = new_session_as :jonas
    assert_equal 0, ImageFile.count
    temp_id = "temp_333"
    file_name = "test_1.jpg"
    conditions = { 'width' => 150, 'height' => 150, 'rotation' => 270, 'filter' => 1 }
    session_id = jonas.session[:session_key]
    
    # Upload a new image. This is a REST call from the upload server
    jonas.post("/widgets/photos", uploaded_file(ImageFile, "photo", file_name, temp_id, session_id, conditions), :accept => "text/xml" )
    jonas.assert_equal 1, ImageFile.count
    image = ImageFile.find(:first)
    jonas.assert_equal file_name, image.filename
    jonas.assert_equal conditions['width'], image.thumb.width
    jonas.assert_equal conditions['height'], image.thumb.height
    jonas.assert_equal conditions['rotation'], image.thumb.rotation
    jonas.assert_equal conditions['filter'], image.thumb.filter
    jonas.assert_equal temp_id, image.upload_id
    jonas.assert_equal jonas.session[:session_key], image.session_id
    
    # Get the photo when the widget isn't saved (through session_key and upload_id)
    jonas.get("/widgets/photo/thumb/#{file_name}", {:photo_id => image.id, :upload_id => temp_id, :conditions => conditions})
    jonas.assert_redirected_to image.thumb.public_uri
    jonas.assert public_amazon(image.thumb.public_uri)
    
    # Get original
    jonas.get("/widgets/photo/file/#{file_name}", {:photo_id => image.id, :upload_id => temp_id, :conditions => conditions})
    jonas.assert_redirected_to image.public_uri
    jonas.assert authenticated_amazon(image.public_uri)
    
    # Non signed in can't get original
    guest = new_session
    guest.get("/widgets/photo/file/#{file_name}", {:photo_id => image.id, :upload_id => temp_id, :conditions => conditions})
    guest.assert_select("h1", "The photo is missing")
    
    old_url = image.thumb.public_uri
    
    # Get the photo when the widget isn't saved (through session_key and upload_id), and regenerate the thumb due to changed conditions
    jonas.get("/widgets/photo/thumb/#{file_name}", {:photo_id => image.id, :upload_id => temp_id, :conditions => { 'width' => 50, 'height' => 50, 'rotation' => 270, 'filter' => 1 }})
    image.reload
    jonas.assert_redirected_to image.thumb.public_uri
    jonas.assert_not_equal old_url, image.thumb.public_uri
    
    # Save photo widget
    jonas.update_widget({:board_1 => {:temp_1 => {:widget_id => 2, :top => 200, :left => 200}}})
    widget_id = jonas.assigns(:boards)[0][1][0][1].to_s
    jonas.assert_select("new_id", widget_id)
    jonas.assert_select("old_id", "temp_1")
    
    # Associate photo with widget
    new_widget = WidgetPhoto.find(widget_id)
    jonas.update_widget({:board_1 => {"widget_#{widget_id}" => {:widget_id => 2, :photo => {:photo_id => image.id} }}})
    jonas.assert_equal(new_widget.photo.id, image.id)
    
    # Get saved photo widget
    jonas.get("/widgets/photo/file/#{file_name}", {:board_id => 1, :photo_id => image.id, :widget_id => widget_id})
    jonas.assert_redirected_to image.public_uri
    jonas.assert authenticated_amazon(image.public_uri)
    
    jonas.end_session
    guest.end_session
  end
    
  def test_a_document_upload
    DocumentFileResource.any_instance.stubs(:save).returns(true)
    DocumentFile.destroy_all
    jonas = new_session_as :jonas
    assert_equal 0, DocumentFile.count
    temp_id = "temp_3331"
    file_name = "test_2.doc"
    session_id = jonas.session[:session_key]
    
    # Upload a new document. This is a REST call from the upload server
    jonas.post("/widgets/documents", uploaded_file(DocumentFile, "document", file_name, temp_id, session_id), :accept => "text/xml" )
    jonas.assert_equal 1, DocumentFile.count
    doc = DocumentFile.find(:first)
    jonas.assert_equal file_name, doc.filename
    jonas.assert_equal temp_id, doc.upload_id
    jonas.assert_equal jonas.session[:session_key], doc.session_id
    
    # Get the document when the widget isn't saved (through session_key and upload_id)
    jonas.get("/widgets/document/file/#{file_name}", {:document_id => doc.id, :upload_id => temp_id})
    jonas.assert_redirected_to doc.public_uri
    jonas.assert authenticated_amazon(doc.public_uri)
    
    # Non signed in can't get document
    guest = new_session
    guest.get("/widgets/document/file/#{file_name}", {:document_id => doc.id, :upload_id => temp_id})
    guest.assert_select("h1", "The document is missing")
        
    # Save document widget
    jonas.update_widget({:board_1 => {:temp_1 => {:widget_id => 3, :top => 200, :left => 200}}})
    widget_id = jonas.assigns(:boards)[0][1][0][1].to_s
    jonas.assert_select("new_id", widget_id)
    jonas.assert_select("old_id", "temp_1")
    
    # Associate document with widget
    new_widget = WidgetDocument.find(widget_id)
    jonas.update_widget({:board_1 => {"widget_#{widget_id}" => {:widget_id => 3, :document => {:document_id => doc.id} }}})
    jonas.assert_equal(new_widget.document.id, doc.id)
    
    # Get saved document widget
    jonas.get("/widgets/document/file/#{file_name}", {:board_id => 1,:document_id => doc.id, :widget_id => widget_id})
    jonas.assert_redirected_to doc.public_uri
    jonas.assert authenticated_amazon(doc.public_uri)
    
    jonas.end_session
    guest.end_session
  end

  def test_copy_file
    jonas = new_session_as :jonas
    image = abstract_files(:image_home_page)
    ImageFileResource.any_instance.stubs(:post).returns(true)
    cloned_image = image.copy
    assert_not_equal cloned_image.id, image.id
    assert_not_nil cloned_image.thumb(:t)
    assert_not_nil cloned_image.thumb(:original)
    assert_not_equal cloned_image.thumb(:t).id, image.thumb(:t).id
    assert_not_equal cloned_image.thumb(:original).id, image.thumb(:original).id
    jonas.end_session
  end
    
  def test_guest_old_file_resize
    guest = new_session_as :guest
    file = abstract_files(:image_home_page)
    ImageFileResource.any_instance.stubs(:save).returns(true)
    guest.get "/widgets/photo/thumb/#{file.filename}?photo_id=#{file.id}&board_id=#{boards(:home_board).id}&widget_id=#{widget_instances(:photo_widget_272_guest).id}&conditions[width]=121&conditions[height]=222&conditions[filter]=1"
    file.thumb(:t).user_authorized = users(:guest).authorized?
    file.thumb(:t).user_base = guest.session[:session_key]
    guest.end_session
  end
  
  def test_user_old_file_resize
    jonas = new_session_as :jonas
    thumb = abstract_files(:thumbnail_thumb_home_page)
    jonas.get "/widgets/photo/thumb/#{thumb.parent.filename}?photo_id=#{thumb.parent.id}&board_id=#{boards(:home_board).id}&widget_id=#{widget_instances(:photo_widget_272_guest).id}&conditions[width]=121&conditions[height]=222&conditions[filter]=1"
    thumb.user_authorized = users(:jonas).authorized?
    thumb.user_base = jonas.session[:session_key]
    jonas.end_session
  end
  
  def test_has_changed
    jonas = new_session_as :jonas
    file = abstract_files(:image_home_page)
    jonas.assert_equal false, file.thumb(:t).has_changed?(:width => "100", :height => "100", :filter => "0", :rotation => "0")
    jonas.assert_equal true, file.thumb(:t).has_changed?(:width => "101", :height => "100", :filter => "0", :rotation => "0")
    jonas.assert_equal true, file.thumb(:t).has_changed?(:width => "100", :height => "101", :filter => "0", :rotation => "0")
    jonas.assert_equal true, file.thumb(:t).has_changed?(:width => "100", :height => "100", :filter => "1", :rotation => "0")
    jonas.assert_equal true, file.thumb(:t).has_changed?(:width => "100", :height => "100", :filter => "0", :rotation => "1")
    jonas.assert_equal true, file.thumb(:t).has_changed?(:width => "101", :height => "101", :filter => "1", :rotation => "1")
    jonas.end_session
  end  
  
  def test_photo_user_get_original
    jonas = new_session_as :jonas
    original = abstract_files(:image_jonas_board)
    jonas.get "widgets/photo/file/#{original.filename}?widget_id=#{widget_instances(:photo_widget_jonas_board).id}&photo_id=#{original.id}&board_id=#{boards(:jonas_board).id}"
    jonas.assert_redirected_to original.public_uri
    jonas.end_session
  end
  
  def test_document_user_get_original
    jonas = new_session_as :jonas
    original = abstract_files(:document_jonas_board)
    jonas.get "widgets/document/file/#{original.filename}?widget_id=#{widget_instances(:document_widget_jonas_board).id}&document_id=#{original.id}&board_id=#{boards(:jonas_board).id}"
    jonas.assert_redirected_to original.public_uri
    jonas.end_session
  end
  
  def test_guest_not_authorized
    guest = new_session_as :guest
    original = abstract_files(:document_jonas_board)
    guest.get "widgets/document/file/#{original.filename}?widget_id=#{widget_instances(:document_widget_jonas_board).id}&document_id=#{original.id}&board_id=#{boards(:jonas_board).id}"
    guest.assert_response 403
    guest.end_session
  end
  
  def test_return_metadata
    jonas = new_session_as :jonas
    abstract_files(:image_temp_jonas_board).update_attribute(:session_id, jonas.session[:session_key])
    jonas.post "widgets/photo/metadata/1234", :board_id => boards(:first).id
    jonas.assert_select "i[id=uri]", abstract_files(:image_temp_jonas_board).thumb(:t).public_uri
    jonas.assert_select "i[id=photoID]", abstract_files(:image_temp_jonas_board).id.to_s
    jonas.assert_select "i[id=fileName]", abstract_files(:image_temp_jonas_board).filename
    jonas.assert_select "i[id=aspectHeight]", /\d+/
    jonas.assert_select "i[id=aspectWidth]", /\d+/
    jonas.assert_select "i[id=uploadID]", "1234"
    
    abstract_files(:document_temp_jonas_board).update_attribute(:session_id, jonas.session[:session_key])
    jonas.post "widgets/document/metadata/1234", :board_id => boards(:first).id
    jonas.assert_select "i[id=documentID]",abstract_files(:document_temp_jonas_board).id.to_s
    jonas.assert_select "i[id=documentName]", abstract_files(:document_temp_jonas_board).filename
    jonas.assert_select "i[id=uploadID]", "1234"
    
    jonas.end_session
  end

  private
  
  def uploaded_file(klass = ImageFile, root_name = "photo", filename = "test.jpg", upload_id = "temp_12345", session_id = "123456", options = {})
    f = klass.create({:filename => filename, :upload_id => upload_id, :session_id => session_id}.merge(options))
    body = { root_name => f.attributes }
    body[root_name].merge!(:thumbnails => { :t => f.thumb.attributes, :original => f.original.attributes }) if defined? f.thumb
    body[root_name][:thumbnails][:t].merge!(options) if defined?  f.thumb
    f.destroy
    body
  end
  
  def authenticated_local str=""
    return str_includes(str, "widgets/")
  end
  
  def public_amazon str=""
    str_includes(str, "http://s3.amazonaws")
  end
  
  def authenticated_amazon str=""
    str_includes(str, "AWSAccessKeyId")
  end
  
  def str_includes str="", test=""
    str.include?(test)
  end
  
    
end
