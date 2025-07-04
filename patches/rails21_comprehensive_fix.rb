#!/usr/bin/env ruby

puts "Applying comprehensive Rails 2.1 + Ruby 2.7 compatibility patches..."

# 1. Fix ActiveSupport TimeZone circular argument reference
puts "1. Fixing ActiveSupport TimeZone..."
activesupport_path = Dir.glob('/usr/local/bundle/gems/activesupport-*').first
if activesupport_path
  timezone_file = File.join(activesupport_path, 'lib/active_support/values/time_zone.rb')
  if File.exist?(timezone_file)
    content = File.read(timezone_file)
    original_content = content.dup
    
    # Fix the circular argument reference
    content.gsub!(/def parse\(str, now=now\)/, 'def parse(str, now_param=nil)')
    content.gsub!(/time = Time\.parse\(str, now\)/, 'time = Time.parse(str, now_param || Time.now)')
    
    if content != original_content
      File.write(timezone_file, content)
      puts "  ✓ Fixed ActiveSupport TimeZone circular argument reference"
    else
      puts "  - ActiveSupport TimeZone already patched or not found"
    end
  end
end

# 2. Fix ActiveRecord base.rb circular argument reference
puts "2. Fixing ActiveRecord base.rb..."
activerecord_path = Dir.glob('/usr/local/bundle/gems/activerecord-*').first
if activerecord_path
  base_file = File.join(activerecord_path, 'lib/active_record/base.rb')
  if File.exist?(base_file)
    content = File.read(base_file)
    original_content = content.dup
    
    # Fix the circular argument reference
    content.gsub!(/def class_name\(table_name = table_name\)/, 'def class_name(table_name_param = nil)')
    content.gsub!(/class_name = table_name\[table_name_prefix/, 'class_name = (table_name_param || table_name)[table_name_prefix')
    
    if content != original_content
      File.write(base_file, content)
      puts "  ✓ Fixed ActiveRecord base.rb circular argument reference"
    else
      puts "  - ActiveRecord base.rb already patched or not found"
    end
  end
end

# 3. Fix ActionController request.rb alias_method issue
puts "3. Fixing ActionController request.rb..."
actionpack_path = Dir.glob('/usr/local/bundle/gems/actionpack-*').first
if actionpack_path
  request_file = File.join(actionpack_path, 'lib/action_controller/request.rb')
  if File.exist?(request_file)
    content = File.read(request_file)
    original_content = content.dup
    
    # Fix the alias_method issue
    content.gsub!(/alias_method :local_path, :path$/, 'alias_method :local_path, :path if method_defined?(:path)')
    
    if content != original_content
      File.write(request_file, content)
      puts "  ✓ Fixed ActionController request.rb alias_method issue"
    else
      puts "  - ActionController request.rb already patched or not found"
    end
  end
end

# 4. Fix ActionMailer tmail encoding issues
puts "4. Fixing ActionMailer tmail encoding..."
actionmailer_path = Dir.glob('/usr/local/bundle/gems/actionmailer-*').first
if actionmailer_path
  utils_file = File.join(actionmailer_path, 'lib/action_mailer/vendor/tmail-1.2.3/tmail/utils.rb')
  if File.exist?(utils_file)
    content = File.read(utils_file)
    original_content = content.dup
    
    # Fix the problematic regex patterns that cause encoding issues
    # Replace control character range with safer ASCII-only version
    content.gsub!(/control\s*=\s*%Q\|\\x00-\\x1f\\x7f-\\xff\|/, 'control = %Q|\\x00-\\x1f\\x7f|')
    
    # Remove /n flags that cause encoding issues - simpler approach
    content.gsub!(/\/n/, '')
    
    if content != original_content
      File.write(utils_file, content)
      puts "  ✓ Fixed ActionMailer tmail encoding issues"
    else
      puts "  - ActionMailer tmail already patched or not found"
    end
  end
end

# 5. Fix ActionView template_error.rb string/integer coercion issue
puts "5. Fixing ActionView template_error.rb..."
actionpack_path = Dir.glob('/usr/local/bundle/gems/actionpack-*').first
if actionpack_path
  template_error_file = File.join(actionpack_path, 'lib/action_view/template_error.rb')
  if File.exist?(template_error_file)
    content = File.read(template_error_file)
    original_content = content.dup
    
    # Fix the .sum method that causes string/integer coercion error
    # Change from .sum (which expects numbers) to .map.join (which handles strings)
    content.gsub!(/source_code\.sum do \|line\|/, 'source_code.map do |line|')
    content.gsub!(/      end$/, '      end.join("")')
    
    if content != original_content
      File.write(template_error_file, content)
      puts "  ✓ Fixed ActionView template_error.rb string/integer coercion issue"
    else
      puts "  - ActionView template_error.rb already patched or not found"
    end
  end
end

puts "✓ All Rails 2.1 + Ruby 2.7 compatibility patches applied successfully!" 