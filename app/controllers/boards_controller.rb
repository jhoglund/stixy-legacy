class BoardsController < ApplicationController
  before_action :set_board, only: [:show, :edit, :update, :destroy, :share, :invite, :export]
  before_action :require_board_access, only: [:show]
  before_action :require_board_edit, only: [:edit, :update, :destroy]

  def index
    @boards = current_user.boards.recent
    @owned_boards = current_user.owned_boards.recent
  end

  def show
    @widget_instances = @board.widget_instances.by_zindex
    @files = @board.abstract_files.recent
    @board.mark_visited(current_user)
  end

  def new
    @board = Board.new
  end

  def create
    @board = Board.new(board_params)
    @board.created_by = current_user
    @board.updated_by = current_user

    if @board.save
      @board.add_user(current_user, current_user)
      redirect_to @board
      flash[:success] = "Board '#{@board.title}' created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @board.updated_by = current_user
    if @board.update(board_params)
      redirect_to @board
      flash[:success] = "Board updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    title = @board.title
    @board.destroy
    redirect_to boards_path
    flash[:success] = "Board '#{title}' deleted successfully."
  end

  def share
    @invites = @board.invites.recent
  end

  def invite
    email = params[:email]
    message = params[:message]
    
    invite = Invite.create_for_board(@board, current_user, email, message)
    
    if invite.persisted?
      # TODO: Send invitation email
      flash[:success] = "Invitation sent to #{email}"
    else
      flash[:error] = "Failed to send invitation: #{invite.errors.full_messages.join(', ')}"
    end
    
    redirect_to share_board_path(@board)
  end

  def export
    # TODO: Implement board export functionality
    flash[:info] = "Export functionality coming soon!"
    redirect_to @board
  end

  private

  def set_board
    @board = Board.find_by(url: params[:id]) || Board.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:title, :description, :visible, :editable, :pwd_protected, :pwd)
  end
end 