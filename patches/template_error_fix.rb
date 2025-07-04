#!/usr/bin/env ruby

puts "Applying precise template_error.rb fix..."

# Fix ActionView template_error.rb string/integer coercion issue
actionpack_path = Dir.glob('/usr/local/bundle/gems/actionpack-*').first
if actionpack_path
  template_error_file = File.join(actionpack_path, 'lib/action_view/template_error.rb')
  if File.exist?(template_error_file)
    content = File.read(template_error_file)
    original_content = content.dup
    
    # First, revert any previous incorrect changes
    content.gsub!(/\.join\(""\)$/, '')
    content.gsub!(/      end\.join\(""\)/, '      end')
    content.gsub!(/        end\.join\(""\)/, '        end')
    
    # Now apply the correct fix only to the source_extract method
    # Find the source_code.sum block and replace it
    if content.include?('source_code.sum do |line|')
      # Replace sum with map and add join
      content.gsub!(/source_code\.sum do \|line\|/, 'source_code.map do |line|')
      
      # Add .join("") only to the end that follows the map block
      # Look for the specific pattern: map block followed by end, then find the right end
      lines = content.split("\n")
      in_source_extract = false
      map_line_index = nil
      
      lines.each_with_index do |line, index|
        if line.strip == 'def source_extract(indentation = 0)'
          in_source_extract = true
        elsif in_source_extract && line.include?('source_code.map do |line|')
          map_line_index = index
        elsif in_source_extract && map_line_index && line.strip == 'end' && lines[index-1].strip.start_with?('"#{indent}#{line_counter}')
          lines[index] = line.gsub('end', 'end.join("")')
          break
        elsif line.strip == 'end' && in_source_extract && !map_line_index
          in_source_extract = false
        end
      end
      
      content = lines.join("\n")
    end
    
    if content != original_content
      File.write(template_error_file, content)
      puts "✓ Fixed ActionView template_error.rb string/integer coercion issue (precise fix)"
    else
      puts "- ActionView template_error.rb already correctly patched"
    end
  end
end

puts "✓ Template error fix completed!" 