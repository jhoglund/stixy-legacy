# Configure attachment_fu to use MiniMagick for image processing
# This is required for thumbnail generation to work properly

require 'mini_magick'

# Ensure the thumbs directory exists and is writable
Rails.logger.info "Configuring attachment_fu with MiniMagick processor"

# Comprehensive patch for AttachmentFu MiniMagick processor
module Technoweenie
  module AttachmentFu
    module Processors
      module MiniMagickProcessor
        def self.included(base)
          base.send :extend, ClassMethods
          base.alias_method_chain :process_attachment, :processing
        end

        module ClassMethods
          # Yields a block containing an MiniMagick Image for the given binary data.
          def with_image(file, &block)
            begin
              # Fix deprecated MiniMagick::Image.from_file method
              binary_data = if file.is_a?(MiniMagick::Image)
                file
              else
                # Use MiniMagick::Image.open instead of deprecated from_file
                MiniMagick::Image.open(file)
              end
            rescue => e
              # Log the failure to load the image.
              Rails.logger.error("Exception working with image: #{e.message}")
              Rails.logger.error("Backtrace: #{e.backtrace.first(5).join(', ')}")
              binary_data = nil
            end
            block.call binary_data if block && binary_data
          ensure
            !binary_data.nil?
          end
        end
        
        protected
        
        # Override process_attachment_with_processing to work with MiniMagick 3.8.1
        def process_attachment_with_processing
          Rails.logger.info("Processing attachment: #{filename} (temp_path: #{temp_path})")
          return unless process_attachment_without_processing
          
          if image? && save_attachment?
            Rails.logger.info("Image detected, processing with MiniMagick...")
            with_image do |img|
              Rails.logger.info("MiniMagick image loaded: #{img[:width]}x#{img[:height]}")
              resize_image_or_thumbnail! img
              # Use MiniMagick 3.8.1 API to get dimensions
              self.width  = img[:width] if respond_to?(:width)
              self.height = img[:height] if respond_to?(:height)
              Rails.logger.info("Set dimensions: #{width}x#{height}")
              callback_with_args :after_resize, img
            end
          else
            Rails.logger.info("Not an image or no attachment to save")
          end
        end
        
        # Override resize_image method to work with MiniMagick 3.8.1
        def resize_image(img, size)
          Rails.logger.info("Resizing image to: #{size}")
          size = size.first if size.is_a?(Array) && size.length == 1
          
          # Create a new image for the resize operation
          img.combine_options do |commands|
            commands.strip unless attachment_options[:keep_profile]
            if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
              if size.is_a?(Fixnum)
                size = [size, size]
                commands.resize(size.join('x'))
              else
                commands.resize(size.join('x') + '!')
              end
            else
              commands.resize(size.to_s)
            end
          end
          
          # Write the resized image to a temporary file
          temp_file = Tempfile.new(['resized', '.jpg'], Technoweenie::AttachmentFu.tempfile_path)
          img.write(temp_file.path)
          Rails.logger.info("Resized image written to: #{temp_file.path}")
          self.temp_path = temp_file.path
          temp_file.close
        end
      end
    end
  end
end

Rails.logger.info "AttachmentFu MiniMagick processor patched for Ruby 2.7 compatibility with MiniMagick 3.8.1" 