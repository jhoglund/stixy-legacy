module StixyRenderMethods
  def render_as_popup options = {}
    if params[:popup] or ENV["RAILS_ENV"] == "test"
      @inside_popup = true
      @from_popup = params.key?(:from_popup)
      yield self if block_given?
      render :layout => "decorator-popup" and return
    else
      stixyboard_base
      params.merge!({:popup => true, "__method" => request.method})
      options.merge!(:src => params.to_query_string, :width => 1008, :height => 540)
      @popup = options
      render :layout => "decorator-stixyboard", :template => "/board/stixyboard" and return
    end
  end
  
  def render_ajax_result
    @result, @replace, @script = {}, {}, []
    def script code
      @script << code
    end
    def replace id, content
     @replace.merge!({id => content})
    end
    yield self if block_given?
    @result.merge!({:replace => @replace}) unless @replace.empty?
    @result.merge!({:script => @script.join(";")}) unless @script.empty?
    render :json => @result.to_json
  end
  
  def render_popup_close status = nil
    @result = ""
    @header_include = "<script type='text/javascript' src='/resources/default/#{set_session_browser}.js'></script>"
    @header_include << "<script type='text/javascript'>"
    @header_include << "var Global = window.parent.Stixy;"
    @header_include << "</script>"
    @header_include << "<script type='text/javascript'>"
    @header_include << "Global.popup.close();"
    @header_include << "</script>"
    @header_include << "<meta id='#{status.to_s}' />" if status
    @header_include << "<meta id='popup_result' />"
    render :inline => @result, :layout => 'decorator-popup'
  end
  
  def render_popup_result status = nil
    @result, @init, @load, @body, @header, @header_include = "","","","","",""
    def init; @init end
    def load; @load end
    def header; @header end
    def body; @body end
    def error
      yield self if block_given?
    end
    yield self if block_given?
    @header_include << "<script type='text/javascript' src='/resources/default/#{set_session_browser}.js'></script>"
    @header_include << "<script type='text/javascript'>"
    @header_include << "var Global = window.parent.Stixy;"
    @header_include << @init
    @header_include << "Stixy.events.observe(window,'ready',function(){"
    @header_include << "Global.popup.result = document;"
	  @header_include << "Global.popup.announce('return');"
    @header_include << @load
    @header_include << "},false,true);"
    @header_include << "</script>"
    @header_include << "<script type='text/javascript'>"
    @header_include << "Global.popup.close();"
    @header_include << "</script>"
    @header_include << "<meta id='#{status.to_s}' />" if status
    @header_include << "<meta id='popup_result' />"
    @result << @body
    render :inline => @result, :layout => 'decorator-popup'
  end
  
  def render_popup_and_update
    @rpau_result, @rpau_init, @rpau_load, @rpau_header, @rpau_body = "","","","",""
    def init; @rpau_init end
    def load; @rpau_load end
    def header; @rpau_header end
    def body; @rpau_body end
    yield self if block_given?
    render_popup_result do |result|
      result.init << @rpau_init
      result.init << "Global.server.autoSave = true;"
      result.init << "Global.server.canBeSaved = true;"
      result.init << "Global.board.id = #{@board.id||0};"
      result.load << @rpau_load
      result.load << "Global.board.updateAll(#{current_user.pref_ui_board_options}, #{current_user.pref_ui_board_list}, #{current_user.pref_ui_widget_tray});"
      result.header << "<meta id='popup_result_update' />"
      result.body << @rpau_body
    end
  end
  
  def render_html_string *options
    "'#{render_to_string(*options).gsub(/\r\n|\n|\r/, "\\n").gsub(/["']/) { |m| "\\#{m}" }}'"
  end
  
  def javascript_array_response 
    render_options, result = Array.new,  Array.new
    yield render_options
    render_options.each{|item| result << item }
    headers["Content-Type"] = "application/x-javascript"
    render :inline => "[#{result.join(",")}]"
  end
end