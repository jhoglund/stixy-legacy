# Disable ActionMailer to avoid tmail compatibility issues with Ruby 2.7
# This allows the core Rails application to run without email functionality

# Remove ActionMailer from the frameworks list
if defined?(Rails::Initializer)
  Rails::Initializer.class_eval do
    def require_frameworks_with_actionmailer_disabled
      frameworks = configuration.frameworks.dup
      frameworks.delete(:action_mailer)
      configuration.frameworks = frameworks
      require_frameworks_without_actionmailer_disabled
    end
    
    alias_method_chain :require_frameworks, :actionmailer_disabled
  end
end

puts "ActionMailer disabled to avoid Ruby 2.7 compatibility issues" 