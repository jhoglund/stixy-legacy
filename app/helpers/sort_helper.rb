
module SortHelper
  # Initializes the default sort column (default_key) and sort order
  # (default_order).
  #
  # - default_key is a column attribute name.
  # - default_order is 'asc' or 'desc'.
  # - name is the name of the session hash entry that stores the sort state,
  #   defaults to '<controller_name>_sort'.
  #
  def sort_init(default_key, default_order='desc', name=nil)
    @sort_name = name || params[:controller] + '_sort'
    @sort_default = {:key => default_key, :order => default_order}
  end
  
  # Updates the sort state. Call this in the controller prior to calling
  # sort_clause.
  #
  def sort_update()
    if params[:sort_key]
      sort = {:key => params[:sort_key], :order => params[:sort_order]}
    elsif session[@sort_name]
      sort = session[@sort_name]   # Previous sort.
    else
     sort = @sort_default
    end
    session[@sort_name] = sort
  end
  
  # Returns an SQL sort clause corresponding to the current sort state.
  # Use this to sort the controller's table items collection.
  #
  def sort_clause()
    session[@sort_name][:key] + ' ' + session[@sort_name][:order]
  end

  # Returns a link which sorts by the named column.
  #
  # - column is the name of an attribute in the sorted record collection.
  # - The optional caption explicitly specifies the displayed link text.
  # - A sort icon image is positioned to the right of the sort link.
  #
  # <%= sort_header_tag('id', :title => 'Sort by contact ID', {:url => }, :update => 'item-boards') %>
  def sort_header_remote_tag(column, caption=nil, ajax_options={}, html_options={})
    key, order = session[@sort_name][:key], session[@sort_name][:order]
    sort_class = {}
    if key == column
      if order.downcase == 'asc'
        sort_class = {:class => 'board-list-detailed-asc' }
        order = 'desc'
      else
        sort_class = {:class => 'board-list-detailed-desc' }
        order = 'asc'
      end
    else
      order = 'asc'
    end
    caption = titleize(Inflector::humanize(column)) unless caption
    
    if ajax_options[:url].nil?
      ajax_options[:url] = {:sort_key => column, :sort_order => order} 
    else
      ajax_options[:url].merge!({:sort_key => column, :sort_order => order})
    # or
    #  ajax_options[:url][:sort_key] = column
    #  ajax_options[:url][:sort_order] = order
    end
    
    content_tag('th',stixy_remote_link(caption, ajax_options, sort_class))
  end
  
  def nbsp(n)
    '&nbsp;' * n
  end
end