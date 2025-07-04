require 'time'
require 'fileutils'

begin

  # dir_path = "~/Desktop" 
  # app_path = "/Users/jhoglund/Stixy/stixy_trunk/"
  # rake_task = "stixy:test"

  dir_path = "/data/stixy/shared/public/images/pending_storage/"
  app_path = "/data/stixy/current/"
  rake_task = "stixy:upload_to_s3"

  # If the time is one hour after midnight PST (8 hours UTC), set max size to 0. Else, set it to 500 MB
  max_size = (8..8).include?(Time.now.hour) ? 0 : 512000

  summary = IO.popen("du -c #{dir_path} | grep total").readline.gsub(/[^\d]/,"").to_i
  if summary > max_size
    puts "Start uploading of #{summary} bytes..."
    Dir.chdir(app_path) do
      IO.popen("rake #{rake_task} RAILS_ENV=production").readlines.each do |line|
        puts line
      end
    end
    puts "Uploading and cleanup completed at #{Time.now}"
  else
    puts "Nothing to upload"
  end

rescue => msg
  File.open(File.join(RAILS_ROOT, 'log', 'tmpError'),'a+') do |file|
    file.puts "Error in #{__FILE__}:\n#{msg}\n\n"
  end
end