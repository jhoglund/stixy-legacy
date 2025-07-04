class Widgets::DocumentController < Widgets::AbstractFile
  include Widgets::DocumentHelper
  skip_before_filter :supported_browsers, :only => [:file, :index, :upload, :after_upload, :metadata]
  skip_before_filter :login_required
    
  # Handle form uploads from the upload popup
  def index
    create
  end
  
  # RESTfull action, limit it to REST api only
  skip_before_filter :supported_browsers, :login_from_cookie, :set_session_id, :only => :create
  verify :params => "document", :method => "post", :only => :create, :redirect_to => '/'
  def create
    # Handle both multipart form uploads and XML API calls
    respond_to do |format|
      format.html { 
        # Handle file upload from form
        if params[:document] && params[:document][:file]
          document = DocumentFile.new
          document.uploaded_data = params[:document][:file]
          document.upload_id = params[:upload_id]
          document.session_id = session[:session_key] || session.session_id || 'temp_session'
          
          if document.save
            # Redirect to after_upload action
            redirect_to :action => 'after_upload', :file => document.id, :board_id => params[:board_id]
          else
            # Redirect back to upload with error
            redirect_to :action => 'upload', :board_id => params[:board_id], :error => document.errors.full_messages.join(', ')
          end
        else
          head :method_not_allowed 
        end
      }
      format.xml { 
        # if id attribute is present in remote call, then update method is called
        #  - to force using create, user remote_id
        remote_type = params[:document].delete('type') # prevents mass-asignment warning
        document = DocumentFile.new(params[:document])
        document.save!
        headers['Location'] = "http://stixy.com/widgets/document/#{document.id}"
        render :status => :created, :xml => document.to_xml and return
      }
    end
  end
  
  # displays a document associated with a widget instance
  def file
    begin
      for_authorized_board do |board|
        if widget = WidgetDocument.find_by_id_and_board_id((params[:widget_id]||0), board.id)
          document = widget.documents.find_by_id(params[:document_id]) # widget has been saved 
        end
        unless document
          document = DocumentFile.find_temp(params[:document_id], params[:upload_id], session[:session_key]) # widget has not been saved
        end
        set_path_base(document, board)
        send_original_file(document)
      end
    rescue
      raise MiscError.new(:title => "The document is missing", :message => "The address for the document is not valid. The address could be old or the document might have been removed from the Stixyboard it ones belonged to.")
    end
  end
  
  # Upload popup
  def upload
    @board = get_board
    if params[:error]
      flash[:error] = case params[:error]
      when /Content type can't be blank/
          "You must first <b>select a document to upload</b> by clicking on the button on the right of the text field bellow."
      when /Size is not included/		
          "The maximum allowed file size for documents is <b>50 MB.</b>"
      else
          "We're sorry! There was an <b>unspeciefied error</b> while uploading the document to Stixy."
      end
    end
    render :layout => 'decorator-popup'
  end
  
  # After upload action returns from upload server for non flash uploads
  def after_upload
    @board = get_board
    for_authorized_board do |board|
      file = DocumentFile.find(params[:file])
      render_popup_result do |result|
        result.body << common_metadata(file, @board)
      end and return
    end
  end
  
  def metadata
    for_authorized_board do |board|
      document = DocumentFile.find(:first, :conditions => {:upload_id => params[:id], :session_id => session[:session_key]}, :select => "id, content_type, upload_id, filename")
      set_path_base(document, board)
      headers["Content-Type"] = "text/xml; charset=utf-8"
      render :inline =>  common_metadata(document, board)
    end
  end
  
  # Fix for old implementation
  alias :upload_document_return_metadata :metadata
 
   def common_metadata document, board
     @original = document
     set_path_base(@original, board)
    "<div style='visibility:hidden'><i id='documentID'>#{@original.id}</i><i id='documentName'>#{@original.filename}</i><i id='documentType'>#{get_icon(@original.content_type, @original.filename.gsub(/.*\./,''))}</i><i id='uploadID'>#{@original.upload_id}</i></div>"
   end
end
