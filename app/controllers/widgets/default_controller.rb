class Widgets::DefaultController < Stixyboard
  helper "widgets/note"
  helper "widgets/photo"
  helper "widgets/document"
  helper "widgets/todo"
  helper "calendar"
  skip_before_filter :login_required, :only => :update
  before_filter :session_is_lost, :only => :update
  
  class WidgetError < StandardError #:nodoc:
    attr_accessor :type, :message, :status
    def initialize args={}
      @type = args[:type]   || "UNSPECIFIED"
      @status = args[:status] || 200
      @message = args[:message] || ""
    end
  end
  
  rescue_from WidgetError, :with => :render_widget_error
    
  def render_widget_error exception
    render(:inline => "<?xml version='1.0' encoding='UTF-8'?><error><type>#{exception.type}</type><message>#{exception.message}</message></error>", :content_type => "text/xml", :status => exception.status)
  end
  
  def update
    return unless params[:body] and request.xhr?
    params[:body][:boards].each do |name, board_data|
      board_id = name.scan(/\d+/)[0].to_i rescue 0
      if @board = (board_id == 0) ? create_board : get_authorized_and_editable_board(board_id)
        @boards = []
        current_user.board_modified(@board)
        @board.updated_on = Time.now
        @board.updated_by = current_user
        widgets = []
        unless board_data.nil?
          board_data.each_with_index do |data, index|
            widget_data = clean_up(data.last)
            widget_instance_id = data.first.match(/widget_(\d*)/)[1] rescue nil
            widget_type = Widget.find(widget_data[:widget_id], :select => :name).name
            widget_class = Object.const_get("Widget#{widget_type}")
            widget = widget_class.find_for_user(widget_instance_id, current_user.id) unless widget_instance_id.nil?
            if widget and widget_data[:remove]=='true'
              widget.disable
            elsif widget_data[:clone_to] and clone_to = get_authorized_and_editable_board(widget_data[:clone_to])
              if widget
                clone = widget.copy(:no_reminders)
                zindex = clone_to.widget_instances.find(:first, :select => "max(zindex) as zindex").zindex
                clone.update_attributes(:board_id => clone_to.id, :top => (clone_to.top+80+(index*10)), :left => (clone_to.left+10+(index*10)), :zindex => (zindex.to_i+1))
                cache_board_fragment(clone_to)
              end
            else
              if widget.nil?
                widget = widget_class.new(:widget_name => widget_class.name)
                @board.widget_instances << widget
              end
              clean_up_zindex(widget_data)
              widget = eval("Widgets::#{widget_type}Controller").update_widget(widget, widget_data, current_user)
              widget.attributes = widget_data
              widget.save!
            end
            @board.save
            widgets.push([data.first, widget.id])
          end
        end
        @boards.push(["board_#{@board.id}",widgets])
      else
        raise WidgetError.new(:type => "UNAUTORIZED", :message => "Your not authorized to do this action.")
      end
    end
    cache_board_fragment(@board)
    render(:layout => false, :content_type => "text/xml")
  end
    
  def optionbar board_id
    #sleep 5
    @board = Board.find(board_id)
    render :update do |page|
      page.insert_html :bottom, "widget_options", :partial => "widgets/#{params[:id]}/options"
      page << IO.read("#{RAILS_ROOT}/public/javascripts/widgets/#{params[:id]}/options.js")
    end
  end
  
  protected
  
   
  def self.update_widget widget, params, user
    return widget
  end
  
  def clean_up widget_data
    # Clean-up widget data. There is a bug in the stixy.js file that results in a widget being submitet as
    # multiple instances in the xml post. When two or more xml nodes has the same name (<widget_nnn>)
    # rails combines the data of the nodes in an array and assigns the array as the value of a hash key named
    # after the node names. The fix below iterates through the array and megers all the members of the array into
    # a single hash. If there is conflicting key names, the later key will overwrite the former key, which could
    # leade to the lost of data. This bug has to be resolved on the client side (stixy.js) at a later stage. 
    # See bug ticket 35 (https://www.stixy.com/trac/ticket/35)
    if widget_data.instance_of?(Array)
      # javascript_logger.server "Recieved multiple hashes for one widget: the data was #{widget_data.to_yaml}"
      tmp_hash = HashWithIndifferentAccess.new
      widget_data.each { |i| tmp_hash.merge!(i) }
      widget_data = tmp_hash
    end
    return widget_data
  end
  
  def clean_up_zindex widget_data
    # Synchronizes the time parameter for a user so zindex is the save for users in different time zones
    time = params[:body][:time]
    zindex = widget_data[:zindex]
    return widget_data unless time and zindex
    widget_data[:zindex] = WidgetInstance.reset_zindex(zindex,time)
    return widget_data
  end

end
