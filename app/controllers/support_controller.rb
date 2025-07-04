class SupportController < ApplicationController 
  helper :captcha
   
  def index
    @name = logged_in? ? current_user.display_name : ''
    @email = logged_in? ? current_user.email : ''
    render :layout => false
  end

end
