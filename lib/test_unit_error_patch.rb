# Ruby 2.7 compatibility patch for Rails 2.1
# This provides the missing test/unit/error module

# Create the test/unit module if it doesn't exist
unless defined?(Test::Unit)
  module Test
    module Unit
      # Dummy error module for Rails 2.1 compatibility
      module Error
        # This is a placeholder for the missing test/unit/error module
        # Rails 2.1 expects this to exist but it was removed in Ruby 2.7
      end
    end
  end
end

# Also patch the require mechanism to handle test/unit/error
module Kernel
  alias_method :original_require, :require
  
  def require(name)
    if name == 'test/unit/error' && RUBY_VERSION >= '2.7'
      # Return true to indicate the module was "loaded"
      return true
    end
    original_require(name)
  end
end 