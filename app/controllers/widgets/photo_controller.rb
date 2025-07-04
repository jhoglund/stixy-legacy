class Widgets::PhotoController <  Widgets::AbstractFile
  skip_before_filter :supported_browsers, :only => :photo
  skip_before_filter :login_required

  # RESTfull action, limit it to REST api only
  skip_before_filter :supported_browsers, :login_from_cookie, :login_required, :session_is_lost, :only => [:create, :update, :thumb]
  verify :params => "photo", :method => "post", :only => :create, :redirect_to => '/'
  def create
    # An empty response is is expected with a 'Location' header value:
    respond_to do |format|
      format.html { head :method_not_allowed }
      format.xml { 
        # if id attribute is present in remote call, then update method is called
        #  - to force using create, user remote_id
        params[:photo].delete('type') # prevents mass-asignment warning
        thumbs = params[:photo].delete(:thumbnails)
        photo = ImageFile.new(params[:photo])
        photo.save!
        thumbs.each do |key, thumbdata|
          remote_type = thumbdata.delete('type')
          thumb = ThumbnailFile.new(thumbdata)
          thumb.parent_id = photo.id
          thumb.save!
        end
        headers['Location'] = "http://stixy.com/widgets/photos/#{photo.id}"
        render :status => :created, :xml => photo.to_xml(:include => :thumbnails) and return
      }
    end
  end
  
  #verify :params => "photo", :method => "put", :only => :update, :redirect_to => '/'
  def update
    respond_to do |format|
      format.html { head :method_not_allowed }
      format.xml {
        render :text => '', :status => :created 
      }
    end
  end
  
  # displays a photo associated with a widget instance
  def file
    begin
      find_photo do |image|
        send_original_file(image)
      end
    rescue
      raise MiscError.new(:title => "The photo is missing", :message => "The address for the photo is not valid. The address could be old or the photo might have been removed from the Stixyboard it ones belonged to.")
    end
  end
  alias :photo :file
  
  # regenerates the thumb if neccerssary
  def thumb
    find_photo do |image|
      thumb = image.thumb(:t)
      if thumb.has_changed?(params[:conditions])
        options = image.attributes
        options[:thumbnails] = [image.thumb(:t).attributes.merge(params[:conditions]), image.thumb(:original).attributes]
        remote_file = ImageFileResource.new(options)
        remote_file.load(image.certificate)
        remote_file.save
        thumb.update_attributes(params[:conditions])
      end
      redirect_to thumb.public_uri
    end
  end  
  
  # Upload popup
  def upload 
    @board = get_board
    image_errors(params[:error])
    render :layout => 'decorator-popup'
  end
  
  # After upload action returns from upload server for non flash uploads
  def after_upload
    @board = get_board
    for_authorized_board do |board|
      file = ImageFile.find(params[:file])
      render_popup_result do |result|
        result.body << common_metadata(file, @board)
      end and return
    end
  end
  
  def metadata
    for_authorized_board do |board|
      original = ImageFile.find_by_upload_id_and_session_id(params[:id], session[:session_key])
      headers["Content-Type"] = "text/xml; charset=utf-8"
      render :inline => common_metadata(original, board) and return
    end
  end
  
  def common_metadata original, board
    @original = original
    @thumb = @original.thumb(:t)
    set_path_base(@thumb, board)
    "<div style='visibility:hidden'><i id='photoID'>#{@original.id}</i><i id='fileName'>#{@original.filename}</i><i id='aspectHeight'>#{@thumb.height.to_f/((@thumb.height.to_f - @thumb.width.to_f)/2 + @thumb.width.to_f)}</i><i id='aspectWidth'>#{@thumb.width.to_f/((@thumb.height.to_f - @thumb.width.to_f)/2 + @thumb.width.to_f)}</i><i id='photoWidth'>#{@thumb.width}</i><i id='photoHeight'>#{@thumb.height}</i><i id='uri'>#{@thumb.public_uri}</i><i id='uploadID'>#{@original.upload_id}</i></div>"
  end
  
  # Fix for old implementation
  alias :upload_photo_return_metadata :metadata
  
  # def upload_photo_flash
  #   @request.env['HTTP_ACCEPT'] = 'text/xml'
  #   redirect_to "http://#{UPLOAD_SERVER}/widgets/photos", params
  # end
  
  private
  
  def find_photo    
    begin
      for_authorized_board do |board|
        if widget = WidgetPhoto.find_by_id_and_board_id((params[:widget_id]||0), board.id)
          image = widget.photos.find_by_id(params[:photo_id]) # widget has been saved 
        end
        unless image
          image = ImageFile.find_temp(params[:photo_id], params[:upload_id], session[:session_key]) # widget has not been saved
        end
        set_path_base(image, board)
        yield image
      end
    rescue
      raise ::ActionController::RoutingError, "Recognition failed for #{request.path}" and return
    end
  end
      
end
