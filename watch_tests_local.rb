#!/usr/bin/env ruby
# Local test watcher for Rails 2.1.0 (runs outside Docker)
# Usage: ruby watch_tests_local.rb

require 'fileutils'
require 'time'

class LocalTestWatcher
  def initialize
    @last_modified = {}
    @test_commands = {
      'app/models/user.rb' => 'docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/user_test.rb"',
      'app/models/board.rb' => 'docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/board_test.rb"',
      'app/models/widget.rb' => 'docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/widget_test.rb"',
      'test/unit/user_test.rb' => 'docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/user_test.rb"',
      'test/unit/board_test.rb' => 'docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/board_test.rb"',
      'test/unit/widget_test.rb' => 'docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/widget_test.rb"',
      'test/test_helper.rb' => 'docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/user_test.rb"'
    }
    
    @watch_paths = [
      'app/models/',
      'test/unit/',
      'test/test_helper.rb'
    ]
  end
  
  def run_test(command)
    puts "\n🔄 Running: #{command}"
    puts "=" * 60
    system(command)
    puts "=" * 60
    puts "✅ Test completed at #{Time.now.strftime('%H:%M:%S')}\n"
  end
  
  def check_file(file_path)
    return unless File.exist?(file_path)
    
    current_mtime = File.mtime(file_path)
    last_mtime = @last_modified[file_path]
    
    if last_mtime.nil? || current_mtime > last_mtime
      @last_modified[file_path] = current_mtime
      
      # Find matching test command
      @test_commands.each do |pattern, command|
        if file_path.include?(pattern.gsub('*', ''))
          puts "\n📝 File changed: #{file_path}"
          run_test(command)
          break
        end
      end
    end
  end
  
  def watch
    puts "🔍 Local Test Watcher Started - Watching for changes..."
    puts "📁 Watching paths: #{@watch_paths.join(', ')}"
    puts "🐳 Running tests in Docker container"
    puts "⏰ Started at #{Time.now.strftime('%H:%M:%S')}"
    puts "Press Ctrl+C to stop\n"
    
    loop do
      @watch_paths.each do |path|
        if File.directory?(path)
          Dir.glob("#{path}**/*.rb").each { |file| check_file(file) }
        else
          check_file(path)
        end
      end
      
      sleep 2  # Check every 2 seconds
    end
  rescue Interrupt
    puts "\n👋 Test watcher stopped. Goodbye!"
  end
end

# Run the watcher
if __FILE__ == $0
  watcher = LocalTestWatcher.new
  watcher.watch
end 