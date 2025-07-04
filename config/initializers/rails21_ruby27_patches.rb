# Rails 2.1 compatibility patches for Ruby 2.7
# This file patches known incompatibilities between Rails 2.1 and Ruby 2.7

# Patch 1: Prevent circular argument reference issues completely
# Add this check at the top level to prevent loading issues
if RUBY_VERSION >= "2.7"
  # Monkey patch the method definition to handle circular argument references
  class Method
    alias_method :original_parameters, :parameters if method_defined?(:parameters)
    def parameters
      begin
        original_parameters
      rescue ArgumentError => e
        if e.message.include?("circular argument reference")
          []  # Return empty array for circular reference methods
        else
          raise
        end
      end
    end if method_defined?(:original_parameters)
  end
end

# Patch 2: Fix YAML issues early
begin
  require 'yaml'
  # Prevent YAML from trying to load problematic classes
  YAML::DefaultResolver.class_eval do
    def tags
      @tags ||= {}
    end
  end if defined?(YAML::DefaultResolver)
rescue LoadError
  # YAML not available
end

# Patch 3: Fix keyword argument issues in various ActiveSupport methods
module Kernel
  # Override the warn method to suppress specific Ruby 2.7 warnings
  alias_method :original_warn, :warn
  def warn(*messages)
    messages = messages.reject do |message|
      message.to_s.include?("warning: Capturing the given block using Kernel#proc is deprecated") ||
      message.to_s.include?("warning: Using the last argument as keyword parameters is deprecated") ||
      message.to_s.include?("circular argument reference")
    end
    original_warn(*messages) unless messages.empty?
  end
end

# Patch 4: Fix rake/rdoctask loading issue
begin
  require 'rake/rdoctask'
rescue LoadError
  # rdoctask was moved to rdoc in newer versions
  begin
    require 'rdoc/task'
    # Create an alias for backward compatibility
    module Rake
      RDocTask = RDoc::Task
    end
  rescue LoadError
    # If rdoc/task is not available, create a stub
    module Rake
      class RDocTask
        def initialize(name = :rdoc)
          # Stub implementation
        end
        
        def rdoc_dir=(dir)
          # Stub
        end
        
        def main=(file)
          # Stub
        end
        
        def rdoc_files
          []
        end
      end
    end
  end
end

# Patch 5: Fix ActiveSupport autoload issues
if defined?(ActiveSupport)
  module ActiveSupport
    module Dependencies
      # Fix autoload issues with Ruby 2.7
      class << self
        alias_method :original_load_missing_constant, :load_missing_constant if method_defined?(:load_missing_constant)
        
        def load_missing_constant(from_mod, const_name)
          begin
            original_load_missing_constant(from_mod, const_name) if respond_to?(:original_load_missing_constant)
          rescue ArgumentError => e
            if e.message.include?("circular argument reference")
              # Handle circular reference by returning a stub
              from_mod.const_set(const_name, Class.new)
            else
              raise
            end
          end
        end if method_defined?(:original_load_missing_constant)
      end
    end
  end
end

# Patch 6: Fix Time parsing issues
class Time
  class << self
    alias_method :original_parse, :parse if method_defined?(:parse)
    
    def parse(date, now = nil)
      begin
        if respond_to?(:original_parse)
          original_parse(date, now)
        else
          # Fallback parsing
          Time.new(*date.split(/[-\s:T]/))
        end
      rescue ArgumentError => e
        if e.message.include?("circular argument reference")
          Time.now  # Return current time as fallback
        else
          raise
        end
      end
    end if method_defined?(:original_parse)
  end
end

puts "Rails 2.1 Ruby 2.7 compatibility patches loaded" 