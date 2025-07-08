# Suppress Ruby 2.7 warnings for legacy Rails 2.1 compatibility
# This file suppresses warnings that are not actionable in our legacy codebase

# Suppress URI.escape/unescape warnings (coming from Rails framework)
Warning[:deprecated] = false

# Suppress specific warnings by monkey patching
module WarningSuppression
  def warn(message)
    # Suppress URI.escape/unescape warnings
    return if message.include?('URI.escape is obsolete') || 
              message.include?('URI.unescape is obsolete') ||
              message.include?('rb_check_safe_obj will be removed') ||
              message.include?('nested repeat operator') ||
              message.include?('already initialized constant') ||
              message.include?('previous definition of RDocTask was here') ||
              message.include?('rb_check_safe_obj will be removed in Ruby 3.0')
    
    # Suppress Mocha deprecation warnings
    return if message.include?('Change `require \'mocha\'` to `require \'mocha/setup\'`')
    
    # Suppress duplicate hash key warnings (we've fixed these in our code)
    return if message.include?('key "') && message.include?('is duplicated and overwritten')
    
    # Call original warn method for other warnings
    super(message)
  end
end

# Apply the warning suppression
Warning.singleton_class.prepend(WarningSuppression) 