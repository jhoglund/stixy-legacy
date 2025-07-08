# lib/rails21_bigdecimal_yaml_as_patch.rb
if RUBY_VERSION >= '2.7'
  # Patch BigDecimal itself
  class ::BigDecimal
    def self.yaml_as(tag)
      # no-op
    end
  end

  # Patch ActiveSupport::CoreExtensions::BigDecimal::Conversions
  module ActiveSupport
    module CoreExtensions
      module BigDecimal
        module Conversions
          def self.yaml_as(tag)
            # no-op
          end
        end
      end
    end
  end
end 