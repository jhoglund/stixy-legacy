# 🧪 Testing Guide for Stixy Rails 2.1.0

## Overview

This Rails 2.1.0 application has been refactored for Ruby 2.7 compatibility. The test system includes both manual testing and automated test watching capabilities.

## ✅ Working Test Approach

### Individual Test Execution (RECOMMENDED)

The most reliable way to run tests is to execute them individually:

```bash
# Run user tests (100% working)
docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/user_test.rb"

# Run board tests
docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/board_test.rb"

# Run widget tests
docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/widget_test.rb"
```

### Test Results Summary

- ✅ **User Tests**: 21/21 tests PASS (90 assertions)
- ✅ **Performance**: 87.99 tests/s
- ✅ **Zero failures, zero errors**

## 🔄 Automated Test Watching

### Option 1: Custom Test Watcher (RECOMMENDED)

We've created a custom test watcher that monitors file changes and automatically runs tests:

```bash
# Start the test watcher (runs locally, tests in Docker)
./start_test_watcher.sh

# Or run directly
ruby watch_tests_local.rb
```

**Features:**
- Watches `app/models/`, `test/unit/`, and `test/test_helper.rb`
- Automatically runs relevant tests when files change
- Runs tests in Docker container for proper Rails 2.1.0 environment
- Clean output with timestamps and emojis
- Easy to stop with Ctrl+C
- Works locally (outside Docker) for better development experience

### Option 2: Guard (Limited Compatibility)

Guard is installed but has compatibility issues with Rails 2.1.0:

```bash
# Install Guard gems (already done)
bundle install

# Try to run Guard (may have issues)
bundle exec guard
```

## 🚫 Known Issues

### Full Test Suite Problems

Running the complete test suite fails due to:

1. **Rails 2.1.0 Fixture System**: Incompatible with Ruby 2.7
2. **Database Setup**: Fixture loading conflicts with pre-populated database
3. **ERB Processing**: Legacy fixture files with ERB cause parsing errors

### Error Examples

```bash
# This will fail:
rake test:units
rake test:functionals

# Errors include:
# - "Array can't be coerced into Integer"
# - "cannot load such file -- test/unit/error"
# - Fixture loading failures
```

## 🛠️ Test Database Setup

The test database is configured with:

```yaml
# config/database.yml
test:
  adapter: sqlite3
  database: db/test.sqlite3
  pool: 5
  timeout: 5000
```

**Database Status:**
- ✅ All 80 migrations marked as complete
- ✅ Test database copied from development
- ✅ All required tables and data present

## 🎯 Recommended Testing Strategy

### 1. Development Workflow

1. **Start the test watcher** in a terminal:
   ```bash
   ./start_test_watcher.sh
   ```

2. **Make changes** to your code

3. **Watch tests run automatically** when you save files

4. **Check results** in the watcher terminal

### 2. Manual Testing

For specific test runs:

```bash
# Test individual models
docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/user_test.rb"

# Test specific functionality
docker-compose exec web bash -c "cd /app && RAILS_ENV=test ruby -Itest test/unit/board_test.rb"
```

### 3. Integration Testing

Test the application manually:

```bash
# Start the application
docker-compose up

# Visit http://localhost:3000
# Test admin interface at http://localhost:3000/admin
```

## 🔧 Test Configuration

### Environment Setup

- **Rails Environment**: `RAILS_ENV=test`
- **Database**: SQLite3 test database
- **ActionMailer**: Disabled (stubbed for Ruby 2.7 compatibility)
- **Fixtures**: Pre-populated database (no fixture loading)

### Test Helper Configuration

The `test/test_helper.rb` includes:
- Rails 2.1.0 compatibility patches
- ActionMailer stubbing
- Database connection setup

## 📊 Test Coverage

### Working Tests

- ✅ User model (21 tests, 90 assertions)
- ✅ User authentication and validation
- ✅ User role management
- ✅ User password handling

### Tests to Add

- Board model tests
- Widget model tests
- Controller functional tests
- Integration tests

## 🚀 Future Improvements

### Potential Upgrades

1. **Modern Test Framework**: Consider upgrading to RSpec or modern minitest
2. **Test Database**: Implement proper fixture loading
3. **CI/CD**: Add automated testing pipeline
4. **Coverage**: Add test coverage reporting

### Immediate Actions

1. **Use the test watcher** for development
2. **Run individual tests** for validation
3. **Manual testing** for integration verification
4. **Document working patterns** for team use

## 📝 Troubleshooting

### Common Issues

**Problem**: Tests fail with fixture errors
**Solution**: Use individual test execution instead of full suite

**Problem**: Guard doesn't work
**Solution**: Use the custom test watcher (`./start_test_watcher.sh`)

**Problem**: Database connection issues
**Solution**: Ensure test database exists and migrations are marked complete

### Getting Help

1. Check this testing guide
2. Review the test watcher output
3. Run individual tests to isolate issues
4. Check the application logs for errors

---

**Last Updated**: $(date)
**Rails Version**: 2.1.0
**Ruby Version**: 2.7.8
**Test Status**: Individual tests working, full suite needs refactoring 