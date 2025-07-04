# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class Admin::AdminApplicationController < ActionController::Base
  layout "layouts/decorator-admin", :except => :boards_ajax
  helper :application
  helper "admin/application"
  include AuthenticatedSystem
  include StixyBrowser
  
  before_filter :login_required, :init_page_size, :doc_type
  
  admin_log_file = File.open(RAILS_ROOT + "/log/admin.log",'w')
  admin_log_file.sync = true
  @@admin_logger = Logger.new(admin_log_file)
  def admin_logger; @@admin_logger end
  
  def init_page_size
    session[:page_size] ||= 50
    session[:page_size] = params[:page_size].to_i if params[:page_size]
  end
  
  def paginate collection, options={}
    clazz = collection.to_s.classify.constantize
    page_size = options.delete(:per_page) || 10
    if order = options.delete(:order_by)
      options[:order] = order
    end
    page_num = params[:page] || 1
    paginator = ::Paginator.new(clazz.count, page_size) do |offset, size|
      clazz.find(:all, options.merge(:offset => offset, :limit => size))
    end
    page = paginator.page(page_num)
    return paginator, page, page.items
  end
  
  # override this from Permission.rb to protect all actions inherited from this controlle to admin only access
  def authorized?
    # authorized if users roles contain map to admin user
    return true if current_user.in_role?(Role::ADMIN)
    # otherwise error
    flash[:error] = "You are not authorized to access this resourse. please login as user with admin privilidges."
    return false
  end
  
  def send_as_admin_email
    default_class = ActionMailer::ARMailer.email_class
    ActionMailer::ARMailer.email_class = AdminEmail
    yield
    ActionMailer::ARMailer.email_class = default_class
  end  
  
  private

end