#!/usr/bin/env ruby

# Script to create flat paths for all photos and thumbnails
require File.dirname(__FILE__) + '/config/environment'

puts "Creating flat paths for all photos and thumbnails..."

# Check existing photos
photos = ImageFile.all
puts "Found #{photos.count} photos to process"

photos.each do |photo|
  puts "Processing: #{photo.filename} (ID: #{photo.id})"
  
  # Check if original file exists
  if File.exist?(photo.full_filename)
    puts "  Original file exists: #{photo.full_filename}"
    
    # Create flat path for photo
    flat_photo_dir = File.join(Rails.root, 'public', 'system', 'photos', photo.id.to_s)
    FileUtils.mkdir_p(flat_photo_dir)
    flat_photo_path = File.join(flat_photo_dir, photo.filename)
    
    unless File.exist?(flat_photo_path)
      begin
        FileUtils.ln_sf(photo.full_filename, flat_photo_path)
        puts "  Created flat photo path: #{flat_photo_path}"
      rescue => e
        FileUtils.cp(photo.full_filename, flat_photo_path)
        puts "  Copied photo to flat path: #{flat_photo_path}"
      end
    else
      puts "  Flat photo path already exists: #{flat_photo_path}"
    end
    
    # Create flat paths for thumbnails
    photo.thumbnails.each do |thumb|
      puts "  Processing thumbnail: #{thumb.thumbnail}"
      
      if File.exist?(thumb.full_filename)
        flat_thumb_dir = File.join(Rails.root, 'public', 'system', 'thumbs', photo.id.to_s)
        FileUtils.mkdir_p(flat_thumb_dir)
        flat_thumb_path = File.join(flat_thumb_dir, thumb.filename)
        
        unless File.exist?(flat_thumb_path)
          begin
            FileUtils.ln_sf(thumb.full_filename, flat_thumb_path)
            puts "    Created flat thumbnail path: #{flat_thumb_path}"
          rescue => e
            FileUtils.cp(thumb.full_filename, flat_thumb_path)
            puts "    Copied thumbnail to flat path: #{flat_thumb_path}"
          end
        else
          puts "    Flat thumbnail path already exists: #{flat_thumb_path}"
        end
      else
        puts "    Thumbnail file missing: #{thumb.full_filename}"
      end
    end
  else
    puts "  Original file missing: #{photo.full_filename}"
  end
end

puts "Flat path creation completed." 