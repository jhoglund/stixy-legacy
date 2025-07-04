# Migration compatibility for SQLite
# This removes MySQL-specific options from create_table statements

if RAILS_ENV == 'development' && ActiveRecord::Base.connection.adapter_name == 'SQLite'
  puts "Loading SQLite migration compatibility patches..."
  
  module ActiveRecord
    module ConnectionAdapters
      module SchemaStatements
        alias_method :create_table_without_mysql_options, :create_table
        
        def create_table(table_name, options = {})
          # Remove MySQL-specific options for SQLite
          if options.is_a?(Hash)
            mysql_options = [:options, :engine, :charset, :collation]
            mysql_options.each { |opt| options.delete(opt) }
            
            # Also remove TYPE=MyISAM from options string
            if options[:options] && options[:options].include?('TYPE=')
              options.delete(:options)
            end
          end
          
          create_table_without_mysql_options(table_name, options) do |table|
            yield(table) if block_given?
          end
        end
      end
    end
  end
  
  puts "SQLite migration compatibility patches loaded"
end 