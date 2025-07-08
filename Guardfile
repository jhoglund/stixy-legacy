# Simple Guardfile for Rails 2.1.0 - focusing on working tests
# More info at https://github.com/guard/guard#readme
# 
# Note: Pry is disabled due to Ruby 2.7 compatibility issues
# Use simple shell commands instead

# Custom guard for running specific working tests
guard :shell do
  # Watch for changes in user model and run user tests
  watch(%r{^app/models/user\.rb$}) { |m| 
    puts "User model changed - running user tests..."
    system("cd /app && RAILS_ENV=test ruby -Itest test/unit/user_test.rb")
  }
  
  # Watch for changes in board model
  watch(%r{^app/models/board\.rb$}) { |m| 
    puts "Board model changed - running board tests..."
    system("cd /app && RAILS_ENV=test ruby -Itest test/unit/board_test.rb")
  }
  
  # Watch for changes in widget models
  watch(%r{^app/models/widget.*\.rb$}) { |m| 
    puts "Widget model changed - running widget tests..."
    system("cd /app && RAILS_ENV=test ruby -Itest test/unit/widget_test.rb")
  }
  
  # Watch for changes in test files
  watch(%r{^test/unit/(.*)\.rb$}) { |m| 
    puts "Test file changed - running #{m[1]}..."
    system("cd /app && RAILS_ENV=test ruby -Itest test/unit/#{m[1]}.rb")
  }
  
  # Watch for changes in test helper
  watch(%r{^test/test_helper\.rb$}) { |m| 
    puts "Test helper changed - running user tests as example..."
    system("cd /app && RAILS_ENV=test ruby -Itest test/unit/user_test.rb")
  }
end

# Notification settings for macOS
notification :terminal_notifier if `uname` =~ /Darwin/ 