# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION
PRIVATE_BETA = false

# Specify Captcha salt key. A random string. This should be the same between the helpdesk app and the stixy app
CAPTCHA_SALT = 'd7fae8c531f140afc2e4ef8598e72cd04d94e806a020092828c08e59111865bd45'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# TEMP fix for solving bug introduced by Mac OSX 10.5.3
# http://objectmix.com/ruby/506748-drb-problems-mac-os-x-10-5-3-a.html

unless ENV['RAILS_ENV'] == 'production'
  require 'drb'
  class DRb::DRbTCPSocket
    class << self
      alias parse_uri_orig parse_uri
      def parse_uri(*args)
        ary = parse_uri_orig(*args)
        ary[1] = nil if ary[1] == 0
        ary
      end
    end
  end
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug
  
  config.gem 'sqlite3'
  config.gem 'icalendar'
  # config.gem 'aws-s3', :lib => 'aws/s3'  # Disabled - using local file storage instead
  #config.gem 'rmagick'
  config.gem 'mini_magick'
  config.gem 'paginator'
  config.gem 'tzinfo'
  #config.gem 'mocha'  # Disabled for Ruby 2.7 compatibility

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store
  config.action_controller.session = {
    :session_key => '_stixy_session',
    :secret      => 'e0cbe020d14a2dd6220b28958154b1ff14af40f3278e8e1dce706666cdd737ec66e744bb58cb2b91e86ad154fbdcaeed878c9f2178b2c3bab9b83128cc27300c'
  }

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
    
end

# ActionController::Base.session_options[:session_key] = (ENV["RAILS_ENV"] == "development") ? 'stixyapp_dev_session_id' : 'stixyapp_session_id'
# CGI::Session.expire_after 1.week.to_i

# This fix is to allow sending emails via gmail smtp server
require 'smtp_tls'
require 'cgi_flash'
require 'stixy_extensions'

#config.action_mailer.logger = Logger.new("#{RAILS_ROOT}/log/mail.log")

# Include your application configuration below
DUMP_PATH = RAILS_ROOT + "/log"