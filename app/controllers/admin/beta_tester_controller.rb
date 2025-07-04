class Admin::BetaTesterController < Admin::AdminApplicationController
  helper :sort
  include SortHelper
  include BetaSignup
  
  def index
    list
    render :action => 'list'
  end

  def list
    sort_init 'id'
    sort_update
    @paginator, @page, @users = paginate :beta_testers, :per_page => session[:page_size], :order_by => sort_clause, :conditions => ["notify_only = ?", params[:notify]=="true" ? 1:0]
  end
  
  def mail
    if request.post?
      if params[:commit]=="Send Invitation"
        if params[:reminder]=="1"
          BetaTester.find(params[:beta_tester].keys, :select => "user_id").each do |bt|
            begin
              invite = Invite.find(:first, :conditions => ["accepted_user_id = ?", bt.user_id])
              Invite.reminder_mail(invite, invite.inviter_user, invite.inviter_user)
            rescue => msg
              admin_logger.info("ERROR #{Time.now.strftime("%B %d, %Y %I:%M %p")}: Couldn't send invitation for Accepted User ID: #{bt.user_id}. Message: #{msg}")
            end
          end
        else
          beta_send_invite(BetaTester.find(params[:beta_tester].keys))
          @users = BetaTester.new_invites
        end
      end
    end
    @users ||= BetaTester.send "all"
    #@users ||= BetaTester.send params[:id]||"all"
  end
    
  def list_with_ajax
    list
    render :partial => 'users_list' 
  end

  def show
    @beta_tester = BetaTester.find(params[:id])
  end

  def new
    @beta_tester = BetaTester.new(:user => User.new)
    @user = @beta_tester.user
  end
  
  def find_all_roles
    return Role.find(:all, :conditions => "status = 1", :limit => 100)
  end

  def create
    @beta_tester = BetaTester.new
    @beta_tester.user = User.new
    if request.post?
      @beta_tester = BetaTester.new(:comment => params[:beta_tester][:comment], :notify_only => params[:beta_tester][:notify_only], :created_by_id =>  current_user.id, :updated_by_id =>  current_user.id)
      @beta_tester.user = User.create(:role_ids => [Role::USER], :pwd => "temp_beta_pwd", :login => params[:user][:login], :login_confirmation => params[:user][:login], :email => params[:user][:login], :status => Status::PENDING, :created_by_id =>  current_user.id, :updated_by_id =>  current_user.id)
      if @beta_tester.save
        flash[:notice] = 'Beta tester was successfully created.'
        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    end
  end

  def edit
    @beta_tester = BetaTester.find(params[:id])
    @user = @beta_tester.user
  end

  def update
   @beta_tester = BetaTester.find(params[:id])
   if @beta_tester.update_attributes(:comment => params[:beta_tester][:comment], :notify_only => params[:beta_tester][:notify_only], :updated_by_id =>  current_user.id) and
     @beta_tester.user.update_attributes(:pwd => "temp_beta_pwd", :login => params[:user][:login], :login_confirmation => params[:user][:login], :email => params[:user][:login], :updated_by_id =>  current_user.id)
     flash[:notice] = 'User was successfully updated.'
     redirect_to :action => 'show', :id => @beta_tester
   else
     render :action => 'edit'
   end
  end
  
  def destroy
    beta_tester = BetaTester.find(params[:id])
    beta_tester.user.destroy
    beta_tester.destroy
    flash[:notice] = 'User was successfully deleted.'
    redirect_to :action => 'list'
  end
end
