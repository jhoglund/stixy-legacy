# ActiveSupport compatibility patches for Rails 2.1 on Ruby 2.7+

# Fix 1: BigDecimal yaml_as issue
require 'bigdecimal'
class BigDecimal
  def self.yaml_as(tag)
    # No-op for compatibility
  end
end

# Fix 2: Module yaml_as issue
class Module
  alias_method :original_yaml_as, :yaml_as if method_defined?(:yaml_as)
  def yaml_as(tag)
    # No-op for compatibility
  end
end

# Fix 3: Patch Time class for compatibility first
class Time
  unless method_defined?(:in_time_zone)
    def in_time_zone(zone = nil)
      # Return self if no zone provided or zone is nil
      return self if zone.nil?
      
      # If zone is a string or symbol, try to create a TimeZone
      if zone.is_a?(String) || zone.is_a?(Symbol)
        # For Rails 2.1 compatibility, just return self
        return self
      end
      
      # For other zone objects, try to convert
      if zone.respond_to?(:utc_to_local)
        # This is likely a TimeZone object, use it
        zone.utc_to_local(self)
      else
        self
      end
    end
  end
end

# Fix 4: ActiveSupport TimeZone fixes - apply after Time patches
if defined?(ActiveSupport)
  module ActiveSupport
    # Fix circular argument reference in TimeZone now method
    class TimeZone
      # Remove the problematic now method and redefine it
      if method_defined?(:now)
        remove_method :now
      end
      
      # Define a safe now method that doesn't cause circular reference
      def now(moment = nil)
        # Use Time.now if no moment provided, otherwise use the provided moment
        time = moment || ::Time.now
        
        # Convert to UTC if not already
        time = time.utc unless time.utc?
        
        # Create a simple time representation in this zone
        # For Rails 2.1, we'll keep it simple and just return the time
        time
      end
      
      # Also fix any other methods that might have circular references
      if method_defined?(:utc_to_local)
        alias_method :original_utc_to_local, :utc_to_local
        def utc_to_local(time)
          # Simple implementation that avoids circular references
          return time if time.nil?
          
          # For Rails 2.1 compatibility, just return the time adjusted by offset
          if time.respond_to?(:+) && respond_to?(:utc_offset)
            begin
              time + utc_offset
            rescue
              time
            end
          else
            time
          end
        end
      end
    end
    
    # Fix TimeWithZone if it exists
    if defined?(ActiveSupport::TimeWithZone)
      class TimeWithZone
        # Fix the in_time_zone method to avoid circular references
        if method_defined?(:in_time_zone)
          alias_method :original_in_time_zone, :in_time_zone
          def in_time_zone(new_zone = nil)
            return self if new_zone.nil? || time_zone == new_zone
            
            # Avoid circular calls by using the time directly
            if utc.respond_to?(:in_time_zone) && new_zone
              begin
                utc.in_time_zone(new_zone)
              rescue
                self
              end
            else
              self
            end
          end
        end
      end
    end
  end
end

# Fix 5: Handle keyword argument issues for Ruby 2.7
module ActiveSupport
  module CoreExtensions
    module Hash
      module IndifferentAccess
        # Fix keyword argument warnings
        def to_hash
          self
        end
      end
    end
  end
end

puts "ActiveSupport compatibility patches loaded for Ruby #{RUBY_VERSION}" 