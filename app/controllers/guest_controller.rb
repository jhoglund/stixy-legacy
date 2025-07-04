class GuestController < ApplicationController
  helper "widgets/default"
  helper "widgets/note"
  helper "widgets/photo"
  helper "widgets/document"
  helper "widgets/todo"
  helper "calendar"
  layout "decorator-guest"
  
  skip_before_filter :supported_browsers, :only => :index
  skip_before_filter :login_required
  
  def index
    if(@board = get_guest_board)
      if @board.protected? and not guest_pwd_access? params[:id]
        redirect_to :action => "password", :id => params[:id]; return
      end
      @edit_view = @board.editable?
      render :template => (@board.editable?) ? "guest/edit" : "guest/index"
    else
      raise ::ActionController::RoutingError, "Recogniation failed for #{request.path}"
    end
  end
 
 # TODO Preview still needs to be done 
 # def preview
 #   if(params[:id]=="password")
 #     preview_password
 #   else
 #     preivew_view
 #   end
 # end
 # 
 # def preivew_view
 #   if(current_user.authorized? and @board = Board.find_by_id(params[:id]))
 #     if params[:pwd_protected]
 #       redirect_to :action => "preview", :id => params[:id], :params => params; return
 #     end
 #     render :template => (params[:editable]=="1") ? "guest/edit" : "guest/index"
 #   else
 #     raise ::ActionController::RoutingError, "Recogniation failed for #{request.path}"
 #   end
 # end
 # 
 # def preview_password
 #   
 # end
  
  def password
    session[:guest] = session[:guest] || []
    if(request.post?)
      if(@board = get_guest_board)
        if(grant_access(@board))
          redirect_to :action => "index", :id => params[:id]
        else flash.now[:signin_missmatch] = { 
          :head => "Wrong password", 
          :body => "The password entered doesn't match with the password for the Stixyboard" 
        }
        end
      end
    end
  end
  
  private
  
  def get_guest_board
    Board.find_by_id(params[:id], :conditions => "visible=1 and status=#{Status::ACTIVE}")
  end
  
  def grant_access board
    return true if guest_pwd_access? params[:id]
    if board.pwd==params[:password]
      session[:guest].push(params[:id].to_s)
      return true
    end
    return false
  end
end
