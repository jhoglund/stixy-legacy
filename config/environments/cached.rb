# So we can pass cookies between upload and main apps. 
# The domain needs to be set up in the host file on the development machine
# Comment the line below to disable this feature during development
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_domain => '.localhost.com')

# Specifies gem version of Rails to use when vendor/rails is not present

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes     = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils        = true

# Enable the breakpoint server that script/breakpointer connects to
## config.breakpoint_server = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true

config.cache_store = :mem_cache_store, '127.0.0.1:11211', {
  :compression => true, 
  :debug => true, 
  :readonly => false, 
  :urlencode => false,
  :namespace => 'stixy_app'
}

ActionMailer::Base.smtp_settings = {
  :address  => "mailout.easydns.com",
  :port  => 587, 
  :domain  => "stixy.com",
  :user_name  => "stixy.com",
  :password  => 'swb34Hs',
  :authentication  => :plain
}

if system('ps -aef | grep -c memcached | grep 2')
  puts ("///////////////////////////")
  puts ("// Start memcache server //")
  puts ("///////////////////////////")
  puts ("")
  puts ("Run: rake memcached:start")
  puts ("or: rake memcached:start mode=daemon")
  puts ("")
  raise StandardError.new("No memcache server available.")
end
#ActionMailer::Base.delivery_method = :activerecord
#ActionMailer::Base.smtp_settings = {
#  :domain             => "stixy.com",
#  :perform_deliveries => true,
#  :address            => 'smtp.ey01.engineyard.com',
#  :port               => 25
#}
#ActionMailer::Base.delivery_method = :activerecord

# ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_domain => 'localhost')

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

#config.action_mailer.logger = Logger.new("#{RAILS_ROOT}/log/mail.log")
SERVER = "localhost"
HELPDESK_SERVER = "helpdesk.localhost.com"
UPLOAD_SERVER = "upload.localhost.com"
RESOURCE_CACHING = false
BLOG_SERVER = "blogserver"