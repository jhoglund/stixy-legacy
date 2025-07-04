class Admin::InviteController < Admin::AdminApplicationController
  
  def index
    list
    render :action => 'list'
  end

  def list
    @paginator, @page, @invites = paginate :invites, :per_page => 50, :order_by => 'updated_on desc' 
  end

  def show
    @invite = Invite.find(params[:id])
  end

  def new
    @boards = Array.new
    @users = User.find :all, nil, 'login ASC'
    @invite = Invite.new
    @invite.status = Status::PENDING
  end
  
  
  def send_reminders *dates
    Invite.send_reminders(*dates)
    list
    render :action => 'list'
  end    

  # create method
  def create
    @boards = Array.new
    @users = User.find :all, nil, 'login ASC'
    @invite = Invite.new(params[:invite])
    
    
    if params[:invite][:inviter_user_id] == nil || params[:invite][:inviter_user_id].empty?
      flash[:error] = 'Inviter user selection is required.'
      render :action => 'new'
      return
    end
    
    if params[:invite][:board_id] == nil || params[:invite][:board_id].empty?
      flash[:error] = 'Board selection is required.'
      render :action => 'new'
      return
    end
    
    # need for preselection in case of error
    @boards = User.find(params[:invite][:inviter_user_id]).boards
    
    if User.find(params[:invite][:accepted_user_id]).boards.include? @invite.board
      flash[:error] = 'User already is a member of this board.'
      render :action => 'new'
      return
    end
    
    # puts @invite.status
    if @invite.save && @invite.board
      Invite.find(@invite.id).update_attributes(:reference_token => User.sha1_no_salt(@invite.id.to_s), :inviter_user_id => params[:invite][:inviter_user_id])
      flash[:notice] = 'Invite was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end


  def edit
    @users = User.find :all, nil, 'login ASC'
    @invite = Invite.find(params[:id])
    @boards = @invite.inviter_user.boards if @invite.inviter_user != nil
  end

  # edit method
  def update
    @users = User.find :all, nil, 'login ASC'
    @invite = Invite.find(params[:id])
    @boards = @invite.inviter_user.boards if @invite.inviter_user != nil
    @invite.accepted_user = User.find(params[:invite][:accepted_user_id]) if params[:invite][:accepted_user_id] != nil
    #puts "Here #{@invite.accepted_user} id: #{params[:id][:accepted_user_id]}"
    #if !@invite.change_user_info?(params)
    #  #@invite.accepted_user = nil
    #  #flash[:error] = 'Invite for those users with this board is already accepted.'
    #  #render :action => 'edit'
    #  #return
    #end
    if @invite.update_attributes(params[:invite]) && @invite.share_board
      flash[:notice] = 'Invite was successfully updated.'
      redirect_to :action => 'show', :id => @invite
    else
      render :action => 'edit'
    end
  end
  
  
  
  
  

  def boards_ajax
    @boards = Array.new
    @boards = User.find(params[:id]).boards if params[:id] != nil
    
  end

  def destroy
    invite = Invite.find(params[:id])
    invite.accepted_user.boards.delete(invite.board)
    invite.destroy
    
    redirect_to :action => 'list'
  end
  
  
  
end
