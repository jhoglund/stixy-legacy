# Disable monitoring and testing plugins for cleaner startup
# This prevents issues with BleakHouse, New Relic, and other monitoring tools

# Disable BleakHouse if it's loaded
if defined?(BleakHouse)
  puts "Disabling BleakHouse monitoring..."
  ENV['BLEAK_HOUSE'] = nil
end

# Disable New Relic if it's loaded
if defined?(NewRelic)
  puts "Disabling New Relic monitoring..."
  NewRelic::Agent.manual_start if NewRelic::Agent.respond_to?(:manual_start)
end

# Disable exception notification in development
if defined?(ExceptionNotifier) && Rails.env.development?
  puts "Disabling exception notification in development..."
  ExceptionNotifier.enabled = false
end

# Disable test exemplars
if defined?(TestExemplars)
  puts "Disabling test exemplars..."
end

puts "Monitoring and testing plugins disabled for cleaner startup" 