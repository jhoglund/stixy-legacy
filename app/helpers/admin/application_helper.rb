module Admin::ApplicationHelper
  def pagination_links_remote(paginator, page, params={}, ajax_options={}, html_options={}, active_class="pager-active")
    pagination_links_each(paginator, page) do |n|
      ajax_options[:url] = params.merge(:page => n)
      unless n==page.number
        stixy_remote_link(n.to_s, ajax_options, html_options.merge({ :class => "number" }))
      else
        content_tag "span", n.to_s, {:class => active_class} 
      end
    end
  end
  def pagination_links_each(paginator, page)
    range_cursor_pos = [page.number - (5/2).floor,1].max
    range_stop = [[page.number + (5/2).ceil,paginator.number_of_pages].min, [paginator.number_of_pages,5].min].max
    html = ''
    if paginator.first.number < range_cursor_pos
      html << yield(paginator.first.number)
      html << ' ... ' if range_cursor_pos - paginator.first.number > 1
      html << ' '
    end
    while current_page = paginator.page(range_cursor_pos) and range_cursor_pos <= range_stop do
      html << yield(current_page.number) << ' '
      range_cursor_pos += 1
    end
    if paginator.page(range_stop).next? 
      html << ' ... ' if paginator.last.number - range_stop > 1
      html << yield(paginator.last.number)
    end
    html
  end
end
