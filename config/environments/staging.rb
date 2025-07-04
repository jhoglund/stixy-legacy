config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
#config.log_level = :debug

config.action_mailer.raise_delivery_errors = true

config.cache_store = :mem_cache_store, 'localhost:11212'
# , {
#   :compression => true, 
#   :debug => true, 
#   :readonly => false, 
#   :urlencode => false,
#   :namespace => 'stixy_app'
# }

dev_smtp_settings = {
  :address  => "mailout.easydns.com",
  :port  => 587, 
  :domain  => "stixy.com",
  :user_name  => "stixy.com",
  :password  => 'swb34Hs',
  :authentication  => :plain
}

config.action_mailer.smtp_settings   = dev_smtp_settings

# So we can pass cookies between upload and main apps
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_domain => '.stixy.com')

SERVER = "staging.stixy.com"
HELPDESK_SERVER = "helpdesk.stixy.com"
UPLOAD_SERVER = "upload.stixy.com"
BLOG_SERVER = "blog.stixy.com"
RESOURCE_CACHING = true

# SERVER = "localhost:3330"
# UPLOAD_SERVER = "localhost:3330"
# RESOURCE_CACHING = false