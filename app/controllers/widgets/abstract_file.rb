class Widgets::AbstractFile <  Widgets::DefaultController
    
  private
  
  def set_path_base file=AbstractFile.new, board=Board.new
    file.user_authorized = current_user.authorized? || board.editable?
    file.user_base = session[:session_key]
  end
  
  def send_original_file file
    redirect_to file.public_uri
  end
  
  def for_authorized_board
    # Ensure board_id is a single value, not an array
    board_id = params[:board_id].is_a?(Array) ? params[:board_id].first : params[:board_id]
    if board = get_authorized_board(board_id)
      yield board
    else
      logger.info("User #{session[:user_id]} attempted to access file for board with id #{board_id} without being authorized")
      render :nothing => true, :status => 403 and return
    end
  end
    
end