#!/usr/bin/env ruby

# Script to clean up orphaned photo records
require File.dirname(__FILE__) + '/config/environment'

puts "Cleaning up orphaned photo records..."

# Get all photos from database
photos = ImageFile.all
puts "Found #{photos.count} photos in database"

orphaned_count = 0
valid_count = 0

photos.each do |photo|
  puts "Checking photo ID #{photo.id}: #{photo.filename}"
  
  # Check if the original file exists
  if File.exist?(photo.full_filename)
    puts "  ✓ Original file exists"
    valid_count += 1
    
    # Check thumbnails
    photo.thumbnails.each do |thumb|
      if File.exist?(thumb.full_filename)
        puts "    ✓ Thumbnail #{thumb.thumbnail} exists"
      else
        puts "    ✗ Thumbnail #{thumb.thumbnail} missing"
      end
    end
  else
    puts "  ✗ Original file missing: #{photo.full_filename}"
    puts "  Deleting orphaned record..."
    
    begin
      # Delete the record and its thumbnails
      photo.destroy
      orphaned_count += 1
      puts "  ✓ Deleted orphaned record"
    rescue => e
      puts "  ✗ Error deleting record: #{e.message}"
    end
  end
end

puts "\nCleanup completed:"
puts "  Valid photos: #{valid_count}"
puts "  Orphaned photos deleted: #{orphaned_count}"
puts "  Remaining photos: #{ImageFile.count}" 