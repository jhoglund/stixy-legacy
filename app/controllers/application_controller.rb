class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Include authentication helpers
  include AuthenticationHelper

  # Set up before_action filters
  before_action :set_current_user
  before_action :require_login, except: [:index, :show, :public]

  # Add flash types
  add_flash_types :success, :error, :warning, :info

  private

  def set_current_user
    @current_user = current_user
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
  end

  def require_login
    unless current_user
      flash[:error] = "Please log in to access this page."
      redirect_to login_path
    end
  end

  def require_board_access
    board = Board.find_by(url: params[:board_id]) || Board.find(params[:board_id])
    unless board.accessible_by?(current_user)
      flash[:error] = "You don't have access to this board."
      redirect_to boards_path
    end
    @board = board
  end

  def require_board_edit
    board = Board.find_by(url: params[:board_id]) || Board.find(params[:board_id])
    unless board.editable_by?(current_user)
      flash[:error] = "You don't have permission to edit this board."
      redirect_to board_path(board)
    end
    @board = board
  end

  def log_in(user)
    session[:user_id] = user.id
    user.update(last_login_date: Time.current)
  end

  def log_out
    session[:user_id] = nil
    @current_user = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end 