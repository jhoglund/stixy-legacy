module AuthenticationHelper
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
  end

  def logged_in?
    !current_user.nil?
  end

  def log_in(user)
    session[:user_id] = user.id
    user.update(last_login_date: Time.current)
  end

  def log_out
    session[:user_id] = nil
    @current_user = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end 