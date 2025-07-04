class UsersController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
  before_action :set_user, only: [:show, :edit, :update]
  before_action :require_owner, only: [:edit, :update]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.password_required = true
    
    if @user.save
      log_in(@user)
      redirect_to root_path
      flash[:success] = "Welcome to Stixy, #{@user.display_name}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @boards = @user.boards.recent.limit(10)
    @files = @user.abstract_files.recent.limit(10)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to @user
      flash[:success] = "Profile updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def boards
    @boards = current_user.boards.recent
  end

  def files
    @files = current_user.abstract_files.recent
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_owner
    unless @user == current_user
      flash[:error] = "You can only edit your own profile."
      redirect_to @user
    end
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :description, :terms_of_service)
  end
end 