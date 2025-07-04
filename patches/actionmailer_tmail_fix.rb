#!/usr/bin/env ruby

puts "Applying ActionMailer tmail utils.rb fix..."

actionmailer_path = Dir.glob('/usr/local/bundle/gems/actionmailer-*').first
if actionmailer_path
  utils_file = File.join(actionmailer_path, 'lib/action_mailer/vendor/tmail-1.2.3/tmail/utils.rb')
  if File.exist?(utils_file)
    content = File.read(utils_file)
    
    # Create a clean version by replacing the problematic method
    content.gsub!(/def dquote\( str \) #:nodoc:.*?end/m) do |match|
      <<~RUBY
        def dquote( str ) #:nodoc:
          unless str =~ /^".*?"$/
            '"' + str.gsub(/["\\\\]/) {|s| '\\\\' + s } + '"'
          else
            str
          end
        end
      RUBY
    end
    
    # Remove any remaining /n flags
    content.gsub!(/\/n(?=\s*[)}])/, '')
    
    # Fix control character definitions
    content.gsub!(/control\s*=\s*%Q\|\\x00-\\x1f\\x7f-\\xff\|/, 'control = %Q|\\x00-\\x1f\\x7f|')
    
    File.write(utils_file, content)
    puts "✓ Fixed ActionMailer tmail utils.rb"
  else
    puts "✗ ActionMailer tmail utils.rb not found"
  end
else
  puts "✗ ActionMailer gem not found"
end 