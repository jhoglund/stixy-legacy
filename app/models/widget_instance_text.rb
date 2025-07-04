#require 'tidy'
class WidgetInstanceText < ActiveRecord::Base
  #begin
  #  Tidy.path = '/usr/lib64/libtidy.so'
  #rescue LoadError
  #  begin 
  #    Tidy.path = '/usr/lib/libtidy.so'
  #  rescue LoadError 
  #    Tidy.path = '/usr/lib/libtidy.A.dylib'
  #  end
  #end
  include ActionView::Helpers::TextHelper
  belongs_to :widget_instance

  def value= text=""
    text = "" if text.nil?
    write_attribute(:value, translate_font_attributes(sanitize(translate_stixy_entities(text.to_s))))
  end

  def value
    "<sx:moz-editor-block-spacer><div></div></sx:moz-editor-block-spacer><sx:moz-editor-cursor-spacer></sx:moz-editor-cursor-spacer>
    #{read_attribute(:value)}"
  end
  
  def clean_value
    "<sx:moz-editor-block-spacer><div></div></sx:moz-editor-block-spacer><sx:moz-editor-cursor-spacer></sx:moz-editor-cursor-spacer>
    #{clean_html(read_attribute(:value))}"
  end
  
  
  protected
  
  def clean_html(html)
    return sanitize html
    #begin
    #  Tidy.open(:show_warnings=>true) do |tidy|
    #    tidy.options.preserve_entities = true
    #    tidy.options.bare = true                                    
    #    tidy.options.hide_comments = true                                     
    #    tidy.options.quiet = true                                   
    #    tidy.options.show_body_only = true                                     
    #    tidy.options.tidy_mark = false
    #    tidy.options.show_warnings = false
    #    tidy.options.show_errors = 0 
    #    tidy.options.input_encoding = 'utf8'
    #    tidy.options.output_encoding = 'raw' 
    #    tidy.options.wrap = 0
    #    tidy.options.literal_attributes = true
    #    tidy.options.fix_uri = false
    #    tidy.clean(html)
    #  end
    #rescue
    #  html
    #end
  end
  
  # Clean the code form scripts, forms etc.
  def sanitize(html)
    # only do this if absolutely necessary
    if !html.nil? && html.index("<")
      html.gsub!(/<script(>|( .*?>)).*?<\/script>/im,"") # remove all SCRIPT tags and anything inside it
      html.gsub!(/<(sx:moz-\S*) (.*?)>(.*?)<\/\1>/m, '<span \2>\3</span>') # rename the node added by firefox even when it has a attribute added
      html.gsub!(/<sx:moz-editor-block-spacer>(.*?)<div>(.*?)<\/div>(.*?)<\/sx:moz-editor-block-spacer>/m, '\1\2\3') # remove the node added by firefox for execCommand to work
      html.gsub!(/<sx:moz-editor-block-spacer>(.*?)<\/sx:moz-editor-block-spacer>/m, '\1') # remove the node added by firefox for execCommand to work
      html.gsub!(/<sx:moz-editor-cursor-spacer>(.*?)<\/sx:moz-editor-cursor-spacer>/, '\1') # remove the node added by firefox for a select all text bug in Firefox 3
      html.gsub!(/<\/?(sx:moz-.*?)>/m, '') # remove any remaining
      html.gsub!(/<\/?form(>|( .*?>)).*?/im,"")
      html.gsub!(/<!--.*?-->/im,"") # remove all COMMENTS
      html.gsub!(/(<\?xml)(:|\s){1}(.*?)(\?|\/){1}(>)/,"") # remove all xml processing instructions (including IE specific)
      tokenizer = HTML::Tokenizer.new(html)
      new_text = ""
      while token = tokenizer.next
        node = HTML::Node.parse(nil, 0, 0, token, false)
        new_text << case node
          when HTML::Tag
            if node.closing != :close
              node.attributes.delete_if { |attr,v| attr =~ /^on/i }
              %w(href src).each do |attr|
                node.attributes.delete attr if node.attributes[attr] =~ /^javascript:/i
              end
            end
            node.to_s
          else
            node.to_s
        end
      end
      html = new_text
    end
    html
  end
  
  def translate_stixy_entities text=""
    return text if text.nil?
    text.gsub(/__STIXYREMOVE__/,"")
  end
  
  # There is most likely a smarter and more efficient way of doing this.
  # I have tryed using Tidy to clean up the code for me, but the right options are missing.
  def translate_font_attributes text
    return text
    text.gsub!(/<font ([^>]*?(color=.*?|face=.*?))>/i){
      style = []; other = []
      $1.split(/\s(?=\w+?=)/i).each do |attribute|
        pair = attribute.split("=")
        case pair[0].downcase
          when "style" then style.unshift(pair[1].gsub(/"|'/, ""))
          when "color" then style.unshift("color: " << pair[1].gsub(/"|'/, ""))
          when "face"  then style.unshift("font-family: '" << pair[1].gsub(/"|'/, "") << "'")
          else other.push(attribute)
        end
      end
      "<font style=\"#{style.join("; ")}\"#{ unless other.empty? then " " + other.join(" ") end }>"
    }
    return text
  end
end
