
class Admin::RoleController < Admin::AdminApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @paginator, @page, @roles = paginate :roles, :per_page => 50, :order_by => 'name asc' 
  end

  def show
    @role = Role.find(params[:id])
  end

  def new
    @role = Role.new
    @role.status = Status::ACTIVE
    @role.is_visible = Role::Yes
    @role.is_locked = Role::No
  end

  def create
    @role = Role.new(params[:role])
    if @role.save
      flash[:notice] = 'Role was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @role = Role.find(params[:id])
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(params[:role])
      flash[:notice] = 'Role was successfully updated.'
      redirect_to :action => 'show', :id => @role
    else
      render :action => 'edit'
    end
  end

  def destroy
    role = Role.find(params[:id])
    if role.users.size != 0
      flash[:error] = 'Unable to delete role. there are users who have it assigned. deassign first or use disablement instead.'
    else
      role.destroy
      flash[:notice] = 'Role was successfully deleted.'
    end
    redirect_to :action => 'list'
  end
end
