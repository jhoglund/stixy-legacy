# Compatibility fix for Rails 2.1 on Ruby 2.7+
# The yaml_as method was removed in newer versions of Ruby

if RUBY_VERSION >= "2.0"
  # Fix for BigDecimal yaml_as issue
  require 'bigdecimal'
  
  class BigDecimal
    def self.yaml_as(tag)
      # This is a no-op for compatibility
    end
  end
  
  # Fix for ActiveSupport BigDecimal extensions
  module ActiveSupport
    module CoreExtensions
      module BigDecimal
        module Conversions
          def self.included(base)
            # Skip the yaml_as call that causes issues
          end
        end
      end
    end
  end
end 