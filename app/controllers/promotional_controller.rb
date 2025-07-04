class PromotionalController < Stixyboard

  def method_missing(method_symbol, *parameters)
    redirect_to '/' and return  #if current_user.authorized?
    #render_cached (['promotional',method_symbol.to_s, params[:id]]).compact.join('/')
  rescue
    redirect_to '/' and return
  end

end
