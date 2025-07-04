#!/bin/bash

# Set up the environment
cd /app

# Load compatibility patches
echo "Loading Rails 2.1 compatibility patches..."
export RUBY_VERSION=$(ruby -v | cut -d' ' -f2)
echo "Running on Ruby $RUBY_VERSION"

# Ensure SQLite database directory exists
echo "Setting up SQLite database..."
mkdir -p db
chmod 755 db

# Check if SQLite database exists, create if not
if [ ! -f "db/development.sqlite3" ]; then
    echo "Creating SQLite database..."
    touch db/development.sqlite3
    chmod 664 db/development.sqlite3
    echo "SQLite database created successfully"
else
    echo "SQLite database already exists"
fi

echo "Attempting to start full Rails application with patches..."

# Try to start the Rails server with our patches
if timeout 30 ruby script/server -p 3000 -b 0.0.0.0 2>&1; then
    echo "Rails server started successfully!"
else
    echo "Rails server failed to start, trying Rails console test..."
    
    # Test if Rails environment loads
    if ruby -e "require './config/boot'; require './config/environment'; puts 'Rails loaded successfully!'" 2>&1; then
        echo "Rails environment loads successfully, trying server again..."
        
        # Try starting the server again
        if ruby script/server -p 3000 -b 0.0.0.0; then
            echo "Rails server started on second attempt!"
        else
            echo "Rails server still fails, falling back to simple server..."
            ruby script/simple_server.rb
        fi
    else
        echo "Rails environment fails to load, falling back to simple server..."
        ruby script/simple_server.rb
    fi
fi 