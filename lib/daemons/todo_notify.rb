
#You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"
Rails::Initializer.run do |config|
    #config.plugins = ['attachment_fu']
end
Rails::Initializer.run(:set_load_path)

loop do
  WidgetTodoReminder.notify
  Notification.deliver
  sleep 60
end