#!/usr/bin/env ruby

# Script to regenerate thumbnails for existing photos
require File.dirname(__FILE__) + '/config/environment'

puts "Regenerating thumbnails for existing photos..."

# Check existing photos
photos = ImageFile.all
puts "Found #{photos.count} photos to process"

photos.each do |photo|
  puts "Processing: #{photo.filename}"
  
  # Check if original file exists
  if File.exist?(photo.full_filename)
    puts "  Original file exists: #{photo.full_filename}"
    
    # Try to regenerate thumbnails
    begin
      # Force thumbnail regeneration by calling the attachment_fu method
      photo.thumbnails.each do |thumb|
        puts "  Regenerating thumbnail: #{thumb.thumbnail}"
        
        # Create directory if it doesn't exist
        FileUtils.mkdir_p(File.dirname(thumb.full_filename))
        
        # Delete existing thumbnail file if it exists
        if File.exist?(thumb.full_filename)
          File.delete(thumb.full_filename)
          puts "    Deleted existing thumbnail file"
        end
        
        # Try to create new thumbnail
        case thumb.thumbnail
        when 't'
          # Create 200px thumbnail
          result = system("convert '#{photo.full_filename}' -resize '200>' '#{thumb.full_filename}'")
        when 'original'
          # Create 600px thumbnail
          result = system("convert '#{photo.full_filename}' -resize '600>' '#{thumb.full_filename}'")
        end
        
        if result && File.exist?(thumb.full_filename)
          puts "    Successfully created thumbnail: #{thumb.full_filename}"
        else
          puts "    Failed to create thumbnail"
        end
        
        # Also ensure flat path for legacy URL compatibility
        if thumb.respond_to?(:ensure_flat_public_path)
          thumb.ensure_flat_public_path
        else
          flat_dir = File.join(Rails.root, 'public', 'system', 'thumbs', thumb.id.to_s)
          FileUtils.mkdir_p(flat_dir)
          flat_path = File.join(flat_dir, thumb.filename)
          FileUtils.ln_sf(thumb.full_filename, flat_path) unless File.exist?(flat_path)
        end
      end
    rescue => e
      puts "  Error processing photo: #{e.message}"
    end
  else
    puts "  Original file missing: #{photo.full_filename}"
  end
  
  # Also ensure flat path for legacy URL compatibility
  if photo.respond_to?(:ensure_flat_public_path)
    photo.ensure_flat_public_path
  else
    flat_dir = File.join(Rails.root, 'public', 'system', 'photos', photo.id.to_s)
    FileUtils.mkdir_p(flat_dir)
    flat_path = File.join(flat_dir, photo.filename)
    FileUtils.ln_sf(photo.full_filename, flat_path) unless File.exist?(flat_path)
  end
end

puts "\nThumbnail regeneration completed." 