class Admin::BoardController < Admin::AdminApplicationController
  helper "widgets/default"
  helper "widgets/note"
  helper "widgets/photo"
  helper "widgets/document"
  helper "widgets/todo"
  helper :board
  helper :sort
  include BoardHelper
  include SortHelper
  
  def index
    list
    render :action => 'list'
  end

  def list
    sort_init 'id'
    sort_update
    @paginator, @page, @boards = paginate :boards, :per_page => session[:page_size], :order_by => sort_clause 
  end
  
  def list_with_ajax
    list
    render :partial => 'board_nav' 
  end
  
  def show
    @board = Board.find(params[:id])
  end
  
  def view
    @board = Board.find(params[:id])
    @user =  current_user
    render :layout => "decorator-stixyboard", :template => "board/stixyboard"
  end
  
  def copy
    @board = Board.find(params[:id])
    @clone = @board.copy
    redirect_to :action => "show", :id => @clone.id
  end
  
  def users
    @board = Board.find(params[:id])
    @users = @board.users
  end
  
  def user_list
    @paginator, @page, @users = paginate :users, :per_page => session[:page_size], :order_by => 'id desc' 
    @board = Board.find(params[:id])
    render :partial => "users_list" if request.xhr?
  end
  
  def add_user
    @board = Board.find(params[:id])
    user = User.find(params[:user])
    user.boardusers.create(:board => @board, :created_by =>  current_user)
    redirect_to :action => "users", :id => @board
  end
  
  def remove_user
    @board = Board.find(params[:id])
    @buser = @board.boardusers.find(:first, :conditions => ["user_id=?",params[:user]])
    @buser.update_attributes(:status => Status::DISABLED, :updated_by =>  current_user)
    redirect_to :action => "users", :id => @board
  end
  
  def new
    @users = User.find :all, nil, 'login ASC'
    @board = Board.new
    @board.status = Status::ACTIVE
  end

  def create
    @users = User.find :all, nil, 'login ASC'
    board_keywords = Board.parse_kwrds(params)
    params[:board][:keyword_ids] = board_keywords.select { | keyword | keyword.id }
    params[:board][:user_ids] = Array[ current_user.id]
    @board = Board.new(params[:board])

    if @board.save
      # hack to save child assosiation - bug in rails 1.0 - http://dev.rubyonrails.org/ticket/3692
      Board.find(@board.id).update_attributes(params[:board])
      flash[:notice] = 'Board was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end 

  def edit
    @users = User.find :all, nil, 'login ASC'
    @board = Board.find(params[:id])
  end

  def update
    @users = User.find :all, nil, 'login ASC'
    @board = Board.find(params[:id])
    pwd = params[:board][:pwd]
    if not pwd.nil? and not pwd.empty?
      params[:board][:pwd] = User.sha1(pwd)
    else
      params[:board][:pwd] = @board.pwd     
    end
    @board.keywords = Board.parse_kwrds(params)
    if @board.update_attributes(params[:board])
      flash[:notice] = 'Board was successfully updated.'
      redirect_to :action => 'show', :id => @board
    else
      render :action => 'edit'
    end
  end
  
  def disable
    begin
      board = Board.find(params[:id])
      board.update_attribute(:status, Status::DISABLED)
      flash[:notice] = 'Board was successfully disabled.'
    rescue => detail
      flash[:error] = detail.backtrace.join("\n")
    end
    redirect_to :action => 'list'
  end
  
  
  def destroy
    begin
      board = Board.find(params[:id])
      board.destroy
      flash[:notice] = 'Board was successfully deleted.'
    rescue => detail
      flash[:error] = detail.backtrace.join("\n")
    end
    redirect_to :action => 'list'
  end
end
