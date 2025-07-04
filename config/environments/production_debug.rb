# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger        = SyslogLogger.new

config.log_level = :debug

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Memcached server
config.cache_store = :mem_cache_store, 'localhost:11211'

config.action_mailer.delivery_method = :sendmail

# So we can pass cookies between upload and main apps
# ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS[:session_domain] = 'localhost'

#ActionMailer::Base.delivery_method = :activerecord

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false

#ENV["RAILS_ENV"] = "production"
SERVER = "localhost"
HELPDESK_SERVER = "helpdesk.localhost.com"
UPLOAD_SERVER = "upload.localhost.com"
RESOURCE_CACHING = true
BLOG_SERVER = "blog.localhost.com"