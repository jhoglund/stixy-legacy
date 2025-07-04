# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger        = SyslogLogger.new

# config.log_level = :debug

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Memcached server
config.cache_store = :mem_cache_store, 'localhost:11211'

smtp_settings = {
  :domain => "stixy.com",
  :address => "mail.blueboxgrid.com",
  :port => "25",
}

config.action_mailer.smtp_settings   = smtp_settings
config.action_mailer.delivery_method = :smtp

# So we can pass cookies between upload and main apps
ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_domain => '.stixy.com')

#ActionMailer::Base.delivery_method = :activerecord

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false

#ENV["RAILS_ENV"] = "production"
SERVER = "www.stixy.com"
HELPDESK_SERVER = "helpdesk.stixy.com"
UPLOAD_SERVER = "upload.stixy.com"
RESOURCE_CACHING = true
BLOG_SERVER = "blog.stixy.com"