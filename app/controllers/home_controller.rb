class HomeController < ApplicationController
  skip_before_action :require_login, only: [:index]

  def index
    if current_user
      @recent_boards = current_user.boards.recent.limit(5)
      @total_boards = current_user.boards.count
      @total_files = current_user.abstract_files.count
      @total_storage = current_user.assets_formatted_size
    else
      @featured_boards = Board.visible.recent.limit(3)
    end
  end
end 