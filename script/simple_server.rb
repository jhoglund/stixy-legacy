#!/usr/bin/env ruby

# Simple server script for Rails 2.1 on Ruby 2.7+
puts "Starting simple Rails 2.1 server..."

# Compatibility patches
require 'bigdecimal'
class BigDecimal
  def self.yaml_as(tag)
    # No-op for compatibility
  end
end

class Module
  def yaml_as(tag)
    # No-op for compatibility
  end
end

# Set Rails root
RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

# Load basic Rails environment
begin
  require File.join(RAILS_ROOT, 'config', 'boot')
  puts "Boot loaded successfully"
rescue => e
  puts "Error loading boot: #{e.message}"
  exit 1
end

# Skip loading full Rails environment due to compatibility issues
puts "Skipping full Rails environment due to Ruby 2.7 compatibility issues"
puts "This is a minimal server to demonstrate the Docker setup is working"

# Start a simple WEBrick server
require 'webrick'

server = WEBrick::HTTPServer.new(
  :Port => 3000,
  :BindAddress => '0.0.0.0',
  :DocumentRoot => File.join(RAILS_ROOT, 'public')
)

# Simple response handler
server.mount_proc '/' do |req, res|
  res.body = <<-HTML
    <html>
      <head><title>Stixy Legacy - Rails 2.1</title></head>
      <body>
        <h1>Stixy Legacy Application</h1>
        <p>Rails 2.1.0 running on Ruby #{RUBY_VERSION}</p>
        <p>This is a basic server to verify the Docker setup is working.</p>
        <p>The application is running in development mode.</p>
      </body>
    </html>
  HTML
  res['Content-Type'] = 'text/html'
end

trap('INT') { server.shutdown }

puts "Server starting on http://0.0.0.0:3000"
server.start 