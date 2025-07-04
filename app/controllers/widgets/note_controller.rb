class Widgets::NoteController < Widgets::DefaultController
  def link
    render_ajax_result do |result|
      #result.script(render_to_string(:partial => "/board/option_script.js.erb"))
      #result.replace :popup_buttons, render_to_string(:inline => "#{ link_to_function "Cancel", 'Stixy.popup.close()', :button => {:type => false} } #{ link_to_function "Save", 'document.forms[0].submit()', :button => {:type => 'default'}, :style => "margin-left:10px;"  }")
      result.replace :popup_content, render_to_string(:inline => "test")
    end
  end
end
