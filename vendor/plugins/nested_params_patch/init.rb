#Dir[File.join(File.dirname(__FILE__), 'lib/*')].each { |file| load file }
Dir[File.join(File.dirname(__FILE__), 'lib/*')].each { |file| require file }

# require File.dirname(__FILE__) + '/lib/array'
# require File.dirname(__FILE__) + '/lib/hash'
# require File.dirname(__FILE__) + '/lib/route'
# require File.dirname(__FILE__) + '/lib/route_set'
