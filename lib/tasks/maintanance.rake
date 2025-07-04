require 'yaml'
require 'rubygems'
require 'active_support'
require 'active_record'

ENV['RAILS_ENV'] ||= 'development'

namespace :stixy do
    desc 'clean up abandoned records prior to doing anything'
    task :remove_sessions do
        connect
        ActiveRecord::Base.establish_connection
        db_connection = ActiveRecord::Base.connection
        db_connection.execute("delete FROM sessions WHERE updated_at < subdate(now(), INTERVAL 6 hour)")
    end
end


def connect
    if ActiveRecord::Base.configurations.nil?  || ActiveRecord::Base.configurations.size == 0
        result = File.read "#{RAILS_ROOT}/config/database.yml"
        result.strip!
        config_file = YAML::load(ERB.new(result).result)
        ActiveRecord::Base.configurations = config_file  
      end
    
end
