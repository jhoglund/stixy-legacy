require 'aws/s3'
require 'net/http'

include AWS::S3  
s3_config = YAML.load_file(RAILS_ROOT + '/config/amazon_s3.yml')[ENV['RAILS_ENV']].symbolize_keys
def bucket_name
  s3_config[:bucket_name]
end

unless Base.connected?
  Base.establish_connection!(
    :access_key_id     => s3_config[:access_key_id],
    :secret_access_key => s3_config[:secret_access_key],
    :server            => s3_config[:server],
    :port              => s3_config[:port],
    :use_ssl           => s3_config[:use_ssl]
  )
end