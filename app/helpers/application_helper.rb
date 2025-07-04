# Application Helper used to be replaced with Base Helper because of bug documented at http://dev.rubyonrails.org/ticket/6001
module ApplicationHelper
  
  def include_resource type, *names
    browser_type = session[:browser] && session[:browser][:type] ? session[:browser][:type] : "other"
    if type.to_sym == :javascript
  	  return javascript_include_tag "/resources/#{names.join('/')}/#{browser_type}"    
    else
      return stylesheet_link_tag "/resources/#{names.join('/')}/#{if current_user.display_ad?; "advertising/" end}#{browser_type}", :media => "all"
    end   
  end
  
  def browser?
    @browser
  end

  def button name, html_options={}
    content_tag("span", name, html_options.merge(:button => {:type => false}))
  end
  
  def stixy_remote_link title, options = {}, html_options = {}, &block
    js = "Stixy.server."
    js << "replace(null,'#{url_for options[:url]}', '#{options[:update]}'" if options[:update]
    js << "connect(null,'#{url_for options[:url]}'" if not options[:update]
    js << ", function(request){#{options[:complete]}}" if options[:complete]
    js << ")"
    js << "; #{options[:before]}" if options[:before]
    link_to_function title, js , html_options
  end
  
  def link_header_unless_current(options = {}, html_options = {})
    unless current_page?(options)
      link_to "", options, html_options
    else
      content_tag "span", "", html_options 
    end
  end
  
  def link_to_popup_nav name, options = {}, html_options = {}, *parameters_for_method_reference, &block
    return (options[:controller]==params[:action]) ? name : link_to(name, options, html_options, *parameters_for_method_reference, &block)
    #url = url.sub(/href=\"\/(.*?)\"/,"href=\"http://#{options[:host]}/\"") if options[:host]
    #return url
  end  
    
  def formated_date(date, offset=true)
    return no_data_str("(N/A)") if date.nil?
  	date = current_user.adjusted_time(date) if offset
    return "Today #{date.strftime("%I:%M %p")}"     if date.strftime("%m/%d/%Y") == Time.now.strftime("%m/%d/%Y")
  	return "Yesterday #{date.strftime("%I:%M %p")}" if date.strftime("%m/%d/%Y") == (Time.now - (60*60*24)).strftime("%m/%d/%Y")
  	return date.strftime("%b %d, %Y") 
  end
  
  def formated_str(data, max=nil, no_data_message="(None)")
    return no_data_str(no_data_message) if data.blank?
    return truncate_by_word(data, max) if max and max < data.size
    return data
  end
  
  def formated_collection(collection, max=nil, no_data_message="(None)")
    return no_data_str(no_data_message) if collection.empty?
    return total_length_str(collection.slice(0..max-1).collect{|c| yield c }.join(", "), collection.size) if max and collection.size > max
    return collection.collect{|c| yield c }.join(", ")
  end
    
  def formated_tooltip
		" title=\"#{yield}\""
	end
  
  def truncate_by_word(data, max)
    return data.slice(/.{0,#{max}}(?=\s)/) + "&nbsp;..." rescue data
  end
  
  def no_data_str(text) 
    return "<span class=\"no-data\">#{text}</span>"
  end

  def total_length_str(collection, total)
    return "#{collection}...&nbsp;(<span class=\"total-length\">#{total.to_s}</span>)"
  end
  
  def popup_default
    [nil, 'height=500,width=600,resizable=yes,scrollbars=yes,']
  end
  
  def wrap_mail mail
    return mail.gsub(/([_\.@-])/){|m| "<span class='no-width-space'>#{m} </span>"}
  end
  

  class TimeSelector
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::TagHelper
    def initialize selected_time, time_format
      @hour, @minute, @suffix = "","",""
      @selected_time = selected_time
      set_time_format(time_format)
    end
    
    def hour object_name, field_name, options = {}
      @hour << select_tag(options[:id] || "#{object_name}_#{field_name}", generate_options(0...23,  @formated_hour), :name => "#{object_name}[#{field_name}]")
    end
    
    def minute object_name, field_name, options = {}
      @minute << select_tag(options[:id] || "#{object_name}_#{field_name}", generate_options(0...59,  @selected_time.min), :name => "#{object_name}[#{field_name}]")
    end
    
    def suffix object_name, field_name, options = {}
      @suffix << select_tag(options[:id] || "#{object_name}_#{field_name}", generate_options(%w{AM PM}, @twelve_hour_prefix), :name => "#{object_name}[#{field_name}]") if @twelve_hour_prefix
    end
    
    def to_s
      return @hour << @minute << @suffix
    end
    
    private
    
    def generate_options range, selected
      options = []
      range.each do |val|
        options << ((val == selected) ?
          %(<option value="#{val}" selected="selected">#{singel_to_double(val)}</option>\n) :
          %(<option value="#{val}"#{}>#{singel_to_double(val)}</option>\n)
        )
      end
      return options
    end
    
    def singel_to_double value=0
      return (value.class == Fixnum and value < 10) ? "0#{value}" : value
    end
    
    def set_time_format time_format
      @formated_hour = @selected_time.hour
      if time_format==true
        @twelve_hour_prefix = "AM"
        if @formated_hour > 12
          @formated_hour = @formated_hour - 12
          @twelve_hour_prefix = "PM"
        end
      end
    end
    
  end

  def time_fields selected_time=Time.new, time_format=true
    time = TimeSelector.new(selected_time,time_format)
    yield time
		return time.to_s
  end
  
  def link_header_unless_current(options = {}, html_options = {})
    unless current_page?(options)
      link_to "", options, html_options
    else
      content_tag "span", "", html_options 
    end
  end
end 