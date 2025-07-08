# Robust patch for Rails 2.1 + Ruby 2.7 BigDecimal yaml_as
# Ensures ActiveSupport::CoreExtensions::BigDecimal::Conversions.yaml_as exists, regardless of load order

if RUBY_VERSION >= '2.7'
  require 'bigdecimal'
  
  # Patch BigDecimal itself
  class ::BigDecimal
    def self.yaml_as(tag)
      # no-op
    end
  end

  # Patch ActiveSupport::CoreExtensions::BigDecimal::Conversions
  patch_proc = Proc.new do
    if defined?(ActiveSupport::CoreExtensions::BigDecimal::Conversions)
      mod = ActiveSupport::CoreExtensions::BigDecimal::Conversions
      unless mod.respond_to?(:yaml_as)
        def mod.yaml_as(tag)
          # no-op
        end
      end
    end
  end

  # Try to patch immediately
  patch_proc.call

  # If not yet defined, hook into Rails reloading
  if defined?(ActionDispatch::Callbacks)
    ActionDispatch::Callbacks.to_prepare { patch_proc.call }
  elsif defined?(ActionController::Dispatcher)
    ActionController::Dispatcher.to_prepare { patch_proc.call }
  else
    # Fallback: try again after initialization
    Rails.configuration.after_initialize { patch_proc.call } if defined?(Rails) && Rails.respond_to?(:configuration)
  end
end 