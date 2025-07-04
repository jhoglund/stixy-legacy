
#You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"

Rails::Initializer.run(:set_load_path)

loop do
  Email.process
  sleep 300
end
