# Fix AttachmentFu thumbnail creation issue with splat operator
# The issue is that attachment_options[:thumbnails] contains strings like "200>" 
# but the create_or_update_thumbnail method tries to splat them

# Wait for AttachmentFu to be loaded, then monkey patch it
Rails.configuration.after_initialize do
  # Reopen the AttachmentFu InstanceMethods module to fix thumbnail creation
  module Technoweenie::AttachmentFu::InstanceMethods
    def after_process_attachment_with_fixed_thumbnails
      if @saved_attachment
        Rails.logger.info("after_process_attachment_with_fixed_thumbnails called for #{filename}")
        Rails.logger.info("  @saved_attachment: #{@saved_attachment}")
        Rails.logger.info("  respond_to?(:process_attachment_with_processing, true): #{respond_to?(:process_attachment_with_processing, true)}")
        Rails.logger.info("  thumbnailable?: #{thumbnailable?}")
        Rails.logger.info("  attachment_options[:thumbnails].blank?: #{attachment_options[:thumbnails].blank?}")
        Rails.logger.info("  parent_id.nil?: #{parent_id.nil?}")
        
        # Fix: Use respond_to? with true to include protected methods
        if respond_to?(:process_attachment_with_processing, true) && thumbnailable? && !attachment_options[:thumbnails].blank? && parent_id.nil?
          temp_file = temp_path || create_temp_file
          Rails.logger.info("Creating thumbnails for #{filename} with temp_file: #{temp_file}")
          
          attachment_options[:thumbnails].each do |suffix, size|
            Rails.logger.info("Creating thumbnail #{suffix} with size #{size}")
            Rails.logger.info("  suffix class: #{suffix.class}, value: #{suffix.inspect}")
            Rails.logger.info("  size class: #{size.class}, value: #{size.inspect}")
            Rails.logger.info("  self.id: #{id.inspect}")
            
            begin
              # Fix: Use raw SQL to bypass ActiveRecord condition parsing issues
              Rails.logger.info("  Using raw SQL to find/create thumbnail")
              Rails.logger.info("  thumbnail_class: #{thumbnail_class}")
              
              # Use raw SQL to find existing thumbnail
              if respond_to?(:parent_id)
                Rails.logger.info("  Finding thumbnail with SQL: thumbnail='#{suffix}', parent_id=#{id}")
                sql = "SELECT * FROM abstract_files WHERE thumbnail = ? AND parent_id = ? AND type = 'ThumbnailFile' LIMIT 1"
                result = ActiveRecord::Base.connection.select_one(sql, [suffix.to_s, id])
                if result
                  Rails.logger.info("  Found existing thumbnail: #{result['id']}")
                  thumbnail = thumbnail_class.find(result['id'])
                else
                  Rails.logger.info("  Creating new thumbnail")
                  thumbnail = thumbnail_class.new
                  thumbnail.thumbnail = suffix.to_s
                  thumbnail.parent_id = id
                end
              else
                Rails.logger.info("  Finding thumbnail with SQL: thumbnail='#{suffix}'")
                sql = "SELECT * FROM abstract_files WHERE thumbnail = ? AND type = 'ThumbnailFile' LIMIT 1"
                result = ActiveRecord::Base.connection.select_one(sql, [suffix.to_s])
                if result
                  Rails.logger.info("  Found existing thumbnail: #{result['id']}")
                  thumbnail = thumbnail_class.find(result['id'])
                else
                  Rails.logger.info("  Creating new thumbnail")
                  thumbnail = thumbnail_class.new
                  thumbnail.thumbnail = suffix.to_s
                end
              end
              
              Rails.logger.info("  Found/created thumbnail: #{thumbnail.class.name} ID=#{thumbnail.id}")
              Rails.logger.info("  Thumbnail attributes before: #{thumbnail.attributes.inspect}")
              
              # Set attributes one by one to debug
              thumbnail.content_type = content_type
              thumbnail.filename = thumbnail_name_for(suffix)
              thumbnail.temp_path = temp_file
              
              Rails.logger.info("  Thumbnail attributes after setting: #{thumbnail.attributes.inspect}")
              Rails.logger.info("  temp_file class: #{temp_file.class}, value: #{temp_file.inspect}")
              
              # Set thumbnail_resize_options as an instance variable instead of attribute
              thumbnail.thumbnail_resize_options = [size]
              Rails.logger.info("  Set thumbnail_resize_options to: #{thumbnail.thumbnail_resize_options.inspect}")
              
              callback_with_args :before_thumbnail_saved, thumbnail
              Rails.logger.info("  About to save thumbnail...")
              thumbnail.save!
              
              # IMPORTANT: Set dimensions after the file is created
              if File.exist?(thumbnail.full_filename)
                begin
                  require 'mini_magick'
                  img = MiniMagick::Image.open(thumbnail.full_filename)
                  thumbnail.width = img[:width]
                  thumbnail.height = img[:height]
                  thumbnail.save!
                  Rails.logger.info("  Set thumbnail dimensions: #{thumbnail.width}x#{thumbnail.height}")
                rescue => e
                  Rails.logger.error("  Failed to set thumbnail dimensions: #{e.message}")
                end
              else
                Rails.logger.error("  Thumbnail file not found: #{thumbnail.full_filename}")
              end
              
              Rails.logger.info("Successfully created thumbnail #{suffix}")
            rescue => e
              Rails.logger.error("Failed to create thumbnail #{suffix}: #{e.message}")
              Rails.logger.error("Backtrace: #{e.backtrace.first(5).join(', ')}")
            end
          end
        else
          Rails.logger.info("Skipping thumbnail creation - conditions not met")
        end
        
        save_to_storage
        @temp_paths.clear
        @saved_attachment = nil
        callback :after_attachment_saved
      else
        Rails.logger.info("after_process_attachment_with_fixed_thumbnails called but @saved_attachment is false")
      end
    end
    
    # Use alias_method_chain to override the original method
    alias_method_chain :after_process_attachment, :fixed_thumbnails
  end
  
  Rails.logger.info "AttachmentFu thumbnail creation fix applied using alias_method_chain"
end 