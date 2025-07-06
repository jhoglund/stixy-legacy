#!/bin/bash
# Start test watcher for Rails 2.1.0 development
# This script runs the test watcher locally (not in Docker)

echo "🚀 Starting Test Watcher for Stixy Rails 2.1.0"
echo "📁 Watching for changes in app/models/, test/unit/, and test/test_helper.rb"
echo "🐳 Tests will run in Docker container"
echo "⏰ Started at $(date)"
echo "Press Ctrl+C to stop"
echo ""

# Run the local test watcher
ruby watch_tests_local.rb 