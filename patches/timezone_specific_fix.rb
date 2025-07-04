#!/usr/bin/env ruby

# Find and patch the specific ActiveSupport TimeZone file
activesupport_path = Dir.glob('/usr/local/bundle/gems/activesupport-*').first

if activesupport_path
  timezone_file = File.join(activesupport_path, 'lib/active_support/values/time_zone.rb')
  puts "Patching ActiveSupport TimeZone file: #{timezone_file}"
  
  if File.exist?(timezone_file)
    # Read the original file
    content = File.read(timezone_file)
    
    # Fix the specific circular argument reference on line 236
    # Change: def parse(str, now=now)
    # To:     def parse(str, now_param=nil)
    content.gsub!(/def parse\(str, now=now\)/) do |match|
      puts "Found and fixing: #{match}"
      "def parse(str, now_param=nil)"
    end
    
    # Also fix the usage of 'now' inside the method
    # Change all references to 'now' to use the safe default
    content.gsub!(/(\s+)time = Time\.parse\(str, now\)/) do |match|
      puts "Found and fixing Time.parse call"
      "#{$1}time = Time.parse(str, now_param || Time.now)"
    end
    
    # Look for other potential circular references in the same file
    content.gsub!(/def (\w+)\([^)]*(\w+)=\2[^)]*\)/) do |match|
      param_name = $2
      puts "Found potential circular reference: #{match}"
      match.gsub(/#{param_name}=#{param_name}/, "#{param_name}_param=nil")
    end
    
    # Write the patched content back
    File.write(timezone_file, content)
    puts "Successfully patched #{timezone_file}"
    
    # Show the patched line for verification
    lines = content.split("\n")
    lines.each_with_index do |line, index|
      if line.include?("def parse")
        puts "Line #{index + 1}: #{line}"
      end
    end
  else
    puts "Error: Could not find TimeZone file at #{timezone_file}"
    exit 1
  end
else
  puts "Error: Could not find ActiveSupport gem path"
  exit 1
end

puts "Patch completed successfully!" 