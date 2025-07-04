class Admin::UserController < Admin::AdminApplicationController
  helper :sort
  include SortHelper
  
  def index
    list
    render :action => 'list'
  end
  
  def list
    #(select sum(size) from abstract_files where user_id=users.id)
    #,"assets"
    sort_init 'users.id'
    sort_update
    @paginator, @page, @users = paginate :users, :per_page => session[:page_size], :include => ["contacts","roles"], :order_by => sort_clause
  end
  
  def user_search
    sort_init 'users.id'
    sort_update
    @paginator, @page, @users = paginate :users, :per_page => session[:page_size], :include => ["contacts","roles"], :conditions => "users.login like '%#{params[:user][:login]}%' or users.login like '#{params[:user][:login]}%' or users.login like '%#{params[:user][:login]}'", :order_by => sort_clause
    render :template => 'admin/user/list' 
  end
  
  def list_with_ajax
    list
    render :partial => 'users_list' 
  end
  
  def login_as
    ## Login as user
    self.current_user = User.find_by_login(params[:id])
    redirect_to :controller => '/'
  end
  
  def show
    @user = User.find(params[:id])
  end

  def new
    @allroles = find_all_roles
    @user = User.new
    @user.role_ids = [3]
    @user.status = Status::ACTIVE
  end
  
  def find_all_roles
    return Role.find(:all, :conditions => "status = 1", :limit => 100)
  end

#  def create
#    @allroles = find_all_roles
#    @user = User.new(params[:user])
#    # This is amazing! no house keeping at all to create the has_and_belongs_to_many
#    # relationship. (see http://wiki.rubyonrails.org/rails/pages/CheckboxHABTM)
#    # There's nothing special about this update method from the
#    # standard scaffold generated update method.  All the "magic" 
#    # is in the automatically generated role_ids= method in the
#    # model called by update_attributes. 
#    if @user.save
#      # hack to save child assosiation - bug in rails 1.0 - http://dev.rubyonrails.org/ticket/3692
#      # but make sure that encrypted password does not get wacked
#      params[:user][:pwd] = @user.pwd
#      User.find(@user.id).update_attributes(params[:user])
#      flash[:notice] = 'User was successfully created.'
#      redirect_to :action => 'list'
#    else
#      render :action => 'new'
#    end
#  end
  
  def create
    @allroles = find_all_roles
    @user = User.new
    if request.post?
      @user = User.new(params[:user])
      # do the user registration
      @user.terms_of_service = "1"
      @user.created_by =  current_user
      @user.updated_by =  current_user
      if @user.save
        flash[:notice] = 'User was successfully created.'
        redirect_to :action => 'list'
      else
        render :action => 'new'
      end
    end
  end

  def edit
    @user = User.find(params[:id])
    @allroles = find_all_roles
  end

  def update
    @allroles = find_all_roles
    @user = User.find(params[:id])
    @user.empty_password = true
    @user.updated_by_id =  current_user.id
    @user.roles.clear if params[:user][:role_id] == nil
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to :action => 'show', :id => @user
    else
      render :action => 'edit'
    end
  end
  
  
  def edit_contacts
    @user = User.find(params[:id])
    @all_users = User.find :all, nil, 'login ASC'
  end
  
  def update_contacts
    contact_id = params[:user][:contact_ids]
    if contact_id.nil? or contact_id.empty?
      flash[:error] = 'Contact selection is required.'
      edit_contacts
      render :action => 'edit_contacts'
      return
    end
    @user = User.find(params[:id])
    @user.contacts << User.find(contact_id)
    @user.save
    flash[:notice] = 'Contact was successfully added.'
    redirect_to :action => 'show', :id => @user
  end

  def destroy
    begin
      user = User.find(params[:id])
      user.destroy
      flash[:notice] = 'User was successfully deleted.'
    rescue => detail
      flash[:error] = detail.backtrace.join("\n")
    end
    redirect_to :action => 'list'  end
end
