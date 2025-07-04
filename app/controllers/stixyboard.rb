# This class holds all shared actions and methods for Public and Board controllers. 
# Any action can be overwritten inside the Public or Board controller classes.

class Stixyboard < ApplicationController
  require 'paginator'
  helper "pagination"
  helper "widgets/default"
  helper "widgets/note"
  helper "widgets/photo"
  helper "widgets/document"
  helper "widgets/todo"
  helper :sort
  helper :board
  include SortHelper
  include BoardHelper
  before_filter :session_is_lost, :only => [:index, :option, :invite, :board_list_detailed]
  #caches_action :index
  
  # STIXYBOARD CANVAS
  
  NON_EDITABLE_SAMPLES = %w{photo_album}
  
  def index
    if request.xhr? 
      show_board_partial
    else
      if current_user.authorized?
        show_board_complete
      else
        if PRIVATE_BETA
          beta_home
        else
          welcome
        end
      end
    end
  end
  
  def beta_home
    render :layout => "decorator-beta", :template => "public/beta_home" and return
  end
    
  
  def welcome
    list_of_boards if current_user.authorized?
    render_cached "home"
  end
    
  def sample
    list_of_boards if current_user.authorized?
    sample_board = case params[:id].to_s
    when "394" then "photo_album"
    when "395" then "shop"
    when "396" then "work"
    else params[:id].to_s
    end
    render_cached "samples/#{sample_board}"
  end
  
  def render_cached path=""
    @cached_dir_path = path
    render :layout => false, :template => "cached/#{@cached_dir_path}/index" if editable_sample
  end
  
  def editable_sample
    return true unless NON_EDITABLE_SAMPLES.include? params[:id].to_s
    render :layout => false, :template => "cached/#{@cached_dir_path}/index" and return false
  end
  
  def widget_options
    @board = get_board
    render :layout => false, :template => "board/widget_options"
  end
      
  # POPUPS
  
  def invite
    render_as_popup do
      @board = get_board
      @feature_partial = "/board/invite"
      render :layout => "decorator-feature" and return
    end
  end
  
  def option
    render_as_popup do
      @board = get_board
      @feature_partial = "/board/option"
      render :layout => "decorator-feature" and return
    end
  end  

  def board_list_detailed
    render_as_popup do
      list_of_boards_detailed
      render :layout => "decorator-popup", :template => "board/board_list_detailed" and return
    end
  end
  
  # POPUP FALLBACKS

  def new_stixyboard
    render_as_popup do
      render :layout => "decorator-public" and return
    end
  end
  
  # AJAX PARTIALS
  
  def flash_upload_player_ajax
    render :partial => "/shared/flash_upload"
  end

  def utility_navigation_ajax
    render :partial => '/shared/utility'
  end

  def options_shared_and_invited_ajax
    @board = get_board
    @board.invites.reload
    render :partial => '/board/options_shared_and_invited'
  end

  def board_shared_and_invited_ajax
    @board = get_board
    @board.invites.reload
    render :partial => '/board/board_shared_and_invited'
  end
  
  def board_option_ajax
    @board = get_board
    render :partial => '/board/board_options'
  end
  
  def board_list_detailed_ajax
    list_of_boards_detailed
    render :partial => '/board/board_list_detailed'
  end
  
  def board_list_compact_ajax
    list_of_boards_compact
    render :partial => '/board/board_list_bar'
  end

  def board_list_compact_item_ajax
    @current = get_board
    render :partial => "/board/board_list_compact_item", :locals => { :board => @current }
  end
  
  # Do nothing for unauthorized user and returns to board
  
  def board_options
    @board = get_board
    render_popup_and_update
  end
  
  # Do nothing for unauthorized user and returns to board
  def create_invite
    @board = get_board
    render_popup_result do |result|
      result.body << "<meta id='error' value='We were unable to sent the invitation.'/>" if @status == :error
    end
  end
  
  # resends the invitation mail to the given invitee
  def send_reminder_ajax
    @board = get_board
    render :update do |page|
      page.replace_html 'options_shared_and_invited', :partial => 'options_shared_and_invited'
   end
  end
  
  
  # displays given users thumbnail or nothing
  # TODO - kill me once we certain nothing uses it anymore
  def personal_thumb
    @thumb_user = User.find(params[:id]) rescue User.new
    redirect_to @thumb_user.avatar_url
  end  
  
  private
  
  def show_board_partial
    @board = get_board
    current_user.board_visited(@board) if params[:id] and current_user.authorized?
    render_ajax_result do |result|
      result.script(render_to_string(:partial => "/board/board_script.js.erb"))
      result.replace :bopt, render_to_string(:partial => "/board/board_options")
      result.replace :canvas_content, render_to_string(:partial => "/board/canvas_content.html.erb")    	  
    end
  end
  
  def show_board_complete
    stixyboard_base
    render :layout => "decorator-stixyboard", :template => "/board/stixyboard"
  end
  
  def stixyboard_base id=0
    @board = current_user.boards.find(params[:id]||id) rescue last_visited_board
    list_of_boards_compact
    current_user.board_visited(@board) if params[:id] and current_user.authorized?
  end
  
  def create_board(options={})
    return Board.new if create_temp_board?
    @board = Board.new({:status => Status::ACTIVE}.merge(options))
    @board.created_by = @board.updated_by = current_user
    @board.boardusers.build(:user => current_user)
    @board.is_new = true
    @board.save
    current_user.board_visited(@board)
    return @board
  end
  
  def create_new_board?
    params[:id].to_s == "0"
  end
  
  def create_welcome_board
    @board = create_board
    @board.update_attribute(:title, "Welcome to Stixy")
    @board
  end
  
  def list_of_boards_detailed
    session[:page_size] ||= 20
    session[:page_size] = params[:page_size].to_i if params[:page_size]
    params[:page_size] = session[:page_size]
    list_of_boards
  end
  
  def list_of_boards_compact
    list_of_boards "boards.updated_on desc", true
  end
  
  def list_of_boards sort_param=nil, include_filters=nil
    @current = current_user.boards.find(params[:id]) rescue last_visited_board
    @invites = current_user.pending_invitations.collect{|invite| invite.board_id }
    sort_init "boards.updated_on"
    sort_update
    params[:page_size] = params[:page_size].blank? ? 10 : params[:page_size].to_i 
    begin
      @board_filters = user_board_filters if include_filters
      @pages = ::Paginator.new(current_user.boards.count_for_list(@board_filters),params[:page_size] ) do |offset, per_page|
        boards = current_user.boards.find_for_list(per_page, offset, sort_clause, @board_filters)
        if boards.empty?
          debug_logger{|log| log.error "Error: Empty set #{Time.now}. User ID: #{current_user.id}. @board_filters => \"#{@board_filters}\"; @board_filters.blank? =>  #{@board_filters.blank?}; @board_filters.class => #{@board_filters.class}" }
        end
        boards
      end
    rescue Board::EmptyFilter
      @pages = ::Paginator.new(0,1){[]}
    end
    @boards = @pages.page(params[:page])
  end
    
  def user_board_filters
    if params[:set_filters]
      if params[:filters] and not params[:filters].blank?
        current_user.board_filters.set(params[:filters].split(",").collect{|k| k.strip!; k unless k.empty? }.compact).collect{|f| f.filter }
      else
        current_user.board_filters.clear_filters
      end
    else
      current_user.board_filters.collect{|f| f.filter }
    end
  end
  
  def last_visited_board
    begin
      if current_user.authorized?
        last = current_user.boardusers.find(:first, :conditions => ["status = ?", Status::ACTIVE], :order => "visited_on desc") 
        return last.board
      else
        Board.new
      end
    rescue => msg
      create_board
    end
  end
  
  def create_temp_board?
    return session[:temp_board] = true unless current_user.authorized?
    remove_temp_board
  end
  
  def temp_board_exist?
    session[:temp_board].nil? ? false : true
  end
  
  def remove_temp_board
    session[:temp_board] = nil
  end
  
  def cache_board_fragment board
    begin
      expire_fragment("board/board_script/#{board.id}");
      expire_fragment("board/board_canvas/#{board.id}");
      expire_fragment("guest/board_canvas/#{board.id}");
      # render_to_string(:partial => "/board/board_script.js.erb")
      # render_to_string(:partial => "/board/board_canvas")    	  
    rescue => msg
      raise MiscError.new(:title => "Fragment cache expiry error in file stixyboard.rb line 300", :message => msg)
    end
  end  
  
      
end