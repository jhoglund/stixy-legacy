# BigDecimal compatibility patch for Ruby 2.7 and Rails 2.1
# This must load before Rails to prevent the yaml_as error

if RUBY_VERSION >= '2.7'
  require 'bigdecimal'
  
  # Monkey patch BigDecimal to add yaml_as method that Rails 2.1 expects
  class BigDecimal
    def self.yaml_as(tag)
      # This is a no-op for Ruby 2.7 compatibility
      # The original method was used for YAML serialization in older Ruby versions
    end
  end
end 