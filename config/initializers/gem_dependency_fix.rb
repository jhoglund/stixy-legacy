# Fix for Rails::GemDependency specification method being private in Ruby 2.7
# This resolves the "private method `specification' called" error

if defined?(Rails::GemDependency)
  Rails::GemDependency.class_eval do
    # Make the specification method public if it exists
    if private_method_defined?(:specification)
      public :specification
    end
    
    # If specification method doesn't exist, create a basic one
    unless method_defined?(:specification)
      def specification
        @specification ||= Gem.source_index.find_name(name, version_requirements).first
      end
    end
  end
end

puts "Rails::GemDependency specification method fixed" 