class Widgets::NoteController < Widgets::DefaultController
  
  def self.update_widget(widget, params, user)
    # Handle text content updates
    if params[:text] && params[:text][:value]
      # Find or create the text record for this widget
      text_record = widget.widget_instance_texts.find(:first, :conditions => ["name IS NULL OR name = ?", "text"])
      if text_record
        text_record.value = params[:text][:value]
        text_record.save!
      else
        # Ensure widget is saved before creating associated records
        widget.save! if widget.new_record?
        widget.widget_instance_texts.create!(:name => "text", :value => params[:text][:value])
      end
      # Remove text from params since it's not a direct widget_instance attribute
      params.delete(:text)
    end
    
    # Handle style updates
    if params[:style]
      params[:style].each do |style_name, style_value|
        # Handle complex style objects like className: {value: "theme", name: "theme"}
        if style_value.is_a?(Hash)
          value = style_value[:value] || style_value["value"]
          attribute = style_value[:name] || style_value["name"]
          # For theme styles, save with name="theme" for template compatibility
          style_name = "theme" if style_name.to_s == "className" && attribute == "theme"
        else
          value = style_value
          # Set attribute field based on style name for template compatibility
          attribute = case style_name.to_s
                     when 'background_color' then 'background_color'
                     when 'opacity' then 'opacity'
                     when 'fill' then 'fill'
                     else nil
                     end
        end
        
        # Find or create the style record
        style_record = widget.widget_instance_styles.find(:first, :conditions => ["name = ?", style_name.to_s])
        if style_record
          style_record.value = value
          style_record.attribute = attribute if attribute
          style_record.save!
        else
          # Ensure widget is saved before creating associated records
          widget.save! if widget.new_record?
          widget.widget_instance_styles.create!(:name => style_name.to_s, :value => value, :attribute => attribute)
        end
      end
      # Remove style from params since it's not a direct widget_instance attribute
      params.delete(:style)
    end
    
    return widget
  end
  
  def link
    render_ajax_result do |result|
      #result.script(render_to_string(:partial => "/board/option_script.js.erb"))
      #result.replace :popup_buttons, render_to_string(:inline => "#{ link_to_function "Cancel", 'Stixy.popup.close()', :button => {:type => false} } #{ link_to_function "Save", 'document.forms[0].submit()', :button => {:type => 'default'}, :style => "margin-left:10px;"  }")
      result.replace :popup_content, render_to_string(:inline => "test")
    end
  end
end
