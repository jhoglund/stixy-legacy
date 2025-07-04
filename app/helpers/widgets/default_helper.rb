module Widgets::DefaultHelper
  def widgets_scripts
    javascript_include_tag "SWFObject", "stixy", *["note","photo","document","todo"].collect!{|name| "widgets/#{name}" }
  end
  def widgets_option_scripts
    javascript_include_tag *["note","photo","document","todo"].collect!{|name| "widgets/#{name}/options" }
  end
  def widgets_styles
    stylesheet_link_tag("widgets/default", *["note","photo","document","todo"].collect!{|name| "widgets/#{name}/widget" } + [:media => "all"])
  end
  def option_bars
    ["note","photo","document","todo"].each do |name|
      render :partial => "widgets/#{name}/options"
    end
  end
end