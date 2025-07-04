class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_to root_path if current_user
  end

  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      log_in(user)
      redirect_back_or(root_path)
      flash[:success] = "Welcome back, #{user.display_name}!"
    else
      flash.now[:error] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_path
    flash[:success] = "You have been logged out successfully."
  end
end 