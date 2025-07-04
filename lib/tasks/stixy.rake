require 'yaml'
require 'rubygems'
require 'active_support'
require 'aws/s3'
require 'erb'


ScriptDir = "db/"
Version_pattern  = Regexp.new("#{ScriptDir}([0-9]*)-.*.sql$")

namespace 'development' do
  task :clean_text => :environment do 
    puts "Total: #{WidgetInstanceText.count}"
    start = Time.now
    WidgetInstanceText.all.each do |w|
      begin
        w.clean_value
      rescue => msg
        puts "Error: #{w.id}; #{msg}"
      end
    end
    puts Time.now - start
  end
  task :bogus_nodes => :environment do
    puts WidgetInstanceText.all.select{|w|
      value = w.read_attribute(:value)
      value =~ /sx:moz-editor-block-spacer/
    }.first.id
  end
  
  task :remove_bogus_nodes => :environment do
    WidgetInstanceText.all.each{|w|
      value = w.read_attribute(:value)
      if value =~ /sx:moz-editor-block-spacer/
        WidgetInstanceTextBackup.create!(w.attributes)
        w.value = value
        w.save! 
      end
    }
  end
  
  task :store_notify_users => :environment do
    board_ids = WidgetInstanceTextBackup.all.map{|t| (t.widget_instance.status == 1 && t.widget_instance.board.status==1) ? t.widget_instance.board.id : nil }.flatten.compact.uniq
    user_ids = WidgetInstanceTextBackup.all.map{|t| t.widget_instance.board.users.map(&:id) }.flatten.uniq
    user_ids.each do |uid|
      user = User.find(uid)
      boards = Board.find(board_ids & user.boards.map(&:id)).map{|board| "#{board.display_name} (http://www.stixy.com/board/#{board.id})\n" } 
      args = { :from => "Stixy Support <support@stixy.com>", :html => false, :to => user.email, :subject => '[Stixy] Important notification from the Stixy team', :content => %Q{
Dear #{user.display_name},

A few weeks back we had a problem with text appearance in some Stixyboard widgets. The bug is now fixed and all effected widgets has been updated.

We found that one or more of your widgets might have been effected. Please check the Stixyboards listed below. If everything looks OK you don't need to take any further action, if not please let us know at support@stixy.com and we'll rollback to the previous version.

The updated widget(s) are located on:
#{boards}

Regards,
The Stixy Team
          } }
      Notifier.store_template_mail(args) if(boards.compact.size > 0)
    end
  end
  
  task :send_notify_users => :environment do
    Notifier.send_stored
  end
end
# task
desc "Rebuild cache for /board/_board_canvas, /board/_board_options, and /board/_board_script"
namespace "memcached" do
  task :rebuild => :environment do
    # av = ActionView::Base.new(Rails::Configuration.new.view_path)  
    # boards = Board.find(:all, :include => ['widget_instances', 'users'], :conditions => "boards.updated_on > date('#{30.days.ago.to_date}')")
    # cache = ActiveSupport::Cache::MemCacheStore.new("127.0.0.1:11211")
    # av.instance_variable_set(:@controller, BoardController.new)
    # boards.each do |board|
    #   current_user = board.updated_by
    #   av.instance_variable_set(:@board, board)
    #   cache.write("views/board/board_script/#{board.id}", av.render(:partial => "board/board_script.js.erb", :locals => { :current_user => current_user }))
    #   cache.write("views/board/board_canvas/#{board.id}", av.render(:partial => "board/board_canvas.rhtml", :locals => { :current_user => current_user }) )
    #   cache.write("views/board/board_options/#{board.id}", av.render(:partial => "board/_board_options.rhtml", :locals => { :current_user => current_user }))
    #   p "ID: #{board.id}, updated on: #{board.updated_on}"
    # end
  end
end
desc "Clearing all js and css files from cache"
namespace "tmp" do
  namespace :cache do
    task :clear_resources do
      FileUtils.rm_rf(Dir['tmp/cache'])
      #FileUtils.rm_rf(Dir['tmp/cache/DATA'])
    end
    task :cr => :clear_resources
  end
end
# task
desc "Creation of the tests database."
namespace "db" do
  namespace :test do
    task :create do
      db_create "test"
    end
  end
end

desc "Creation of the specified database. default is development. Specify test environment using ENV=test"
namespace "db" do
  task :create do
    env_name = (ENV["ENV"] != nil ? ENV["ENV"] : 'development') 
    db_create env_name
  end
end


# task
desc "Deinstallation of the specified database. default is development. Specify test environment using ENV=test"
namespace "db" do
  task :clobber do
    env_name = (ENV["ENV"] != nil ? ENV["ENV"] : 'development') 
    db_clobber env_name
  end
end

# task
desc "Deinstallation of the specified database. default is development. Specify test environment using ENV=test"
namespace "db" do
  namespace :test do
    task :clobber do
      db_clobber "test"
    end
end

# task
desc "Recreates the db"
#namespace "db" do
  task :recreate do
    env_name = (ENV["ENV"] != nil ? ENV["ENV"] : 'development') 
    db_clobber env_name
    db_create env_name
  end
#end
end


# Cron job
# 0  2 * * * cd /home/deploy/current; rake stixy:pending_invitations_reminder > /dev/null &
namespace :stixy do  
  desc 'Send reminders to pending invitations'
  task(:pending_invitations_reminder => :environment) do
    index = 0
    Invite.send_reminders((Date.today - 4), (Date.today - 8), (Date.today - 12)) do |message|
      index = index+1
      msg message
    end
    rake_log do |log|
      log.info "A total of #{index} reminders was sent"
    end
  end
  
  desc 'Download'
  task(:download_thumbs => :environment) do
    s3_conf = setup_s3_connection
    rake_log do |log|
      files = ThumbnailFile.find(:all, :conditions => {:storage_state=>0})
      files.each do |file|
        begin
          if !AWS::S3::S3Object.exists?(file.new_name, 'stixy')
            if AWS::S3::S3Object.exists?(file.old_name, 'stixy')
              path = "/mnt/ebs/home/stixy/tmp/#{file.old_name}"
              FileUtils.mkdir_p(File.dirname(path))
              File.open(path, 'w+') do |temp_file|
                AWS::S3::S3Object.stream(file.old_name, 'stixy') do |chunk|
                  temp_file.write chunk
                end
              end
              file.update_attribute(:storage_state, 18)
              p "Copied file to: #{path}"
            else
              p "Dont exist: #{file.old_name}"
            end
          end
        rescue => m
          p m
        end
      end
    end
  end
  
  desc 'Download'
  task(:download => :environment) do
    s3_conf = setup_s3_connection
    rake_log do |log|
      files = AbstractFile.find(:all, :conditions => {:storage_state=>11})
      files.each do |file|
        begin
          path = "/mnt/ebs/home/stixy/tmp/#{file.old_name}"
          FileUtils.mkdir_p(File.dirname(path))
          File.open(path, 'w+') do |temp_file|
            AWS::S3::S3Object.stream(file.old_name, 'stixy') do |chunk|
              temp_file.write chunk
            end
          end
          file.update_attribute(:storage_state, 30)
          p "Copied file to: #{path}"
        rescue => m
          p m
        end
      end
    end
  end
  
  desc 'Exists?'
  task(:test_uploaded => :environment) do
    require 'net/http'
    s3_conf = setup_s3_connection
    rake_log do |log|
      files = AbstractFile.find(:all, :conditions => 'storage_state<3 or storage_state>9')
      size = files.size.to_f
      files.each_with_index do |file, i|
        begin
          url = URI.parse(file.public_uri)
          if file.require_authentication?
            auth = (Net::HTTP.start(url.host, url.port) {|http| http.request_get(url.path + "?" + url.query) }.class == Net::HTTPOK)
            pub = (Net::HTTP.start(url.host, url.port) {|http| http.request_get(url.path) }.class == Net::HTTPForbidden)
            test = auth and pub
          else
            test = (Net::HTTP.start(url.host, url.port) {|http| http.request_get(url.path) }.class == Net::HTTPOK)
          end
          if test
            log.info "#{file.full_filename}"
            file.update_attribute(:storage_state, 10)
          else
            log.error "#{file.full_filename}"
            file.update_attribute(:storage_state, 11)
          end
        rescue => m
          log.error "#{file.full_filename}"
          file.update_attribute(:storage_state, 12)
        end
        p "#{(i.to_f/size)*100}% tested: #{file.full_filename}"
      end
    end
  end
  
  desc 'Upload'
  task(:upload => :environment) do
    s3_conf = setup_s3_connection
    rake_log do |log|
      files = AbstractFile.find(:all, :conditions => {:storage_state=>30})
      files.each do |file|
        begin
          path = "/mnt/ebs/home/stixy/tmp/#{file.old_name}"
          S3Object.store(file.new_name, open(path), 'stixy', :access => (file.require_authentication? ? :authenticated_read : :public_read))
          file.update_attribute(:storage_state, 31)
          p "Copied file to: #{file.new_name}"
        rescue => m
          p m
        end
      end
    end
  end
  
  
  desc 'Copying old files'
  task(:copy_old => :environment) do
    s3_conf = setup_s3_connection
    index = 0
    acl_index = 0
    error_index = 0
    rake_log do |log|
      files = ([] << AvatarFile.find(:all, :conditions => {:storage_state=>0}) << ImageFile.find(:all, :conditions => {:storage_state=>0}) << DocumentFile.find(:all, :conditions => {:storage_state=>0})).flatten
      files.each do |file|
        file.copy_to_new do |i, msg|
          index += i
          puts "#{Time.now}: #{msg}"
        end
      end
      log.info "#{index} files was succesfully copied."
    end
  end
  
  desc 'Uploading files to S3'
  task(:upload_to_s3 => :environment) do
    try_to_upload
  end
  
  desc 'Clean-up files uploaded to S3'
  task(:remove_uploaded => :environment) do
    removing_uploaded_files()
  end
  
  namespace :mail do
    desc 'Send pending mails'
    task(:send => :environment) do
      ActionMailer::StixyMail::Sender.send
    end
  end
  
  namespace :notification do
    desc 'Send pending notifications'
    task :send => :environment do
      Notifier.send_stored
    end
  end
end

# -------------------- 
# Implementation details
# -------------------- 

def setup_s3_connection
  s3_config_path = RAILS_ROOT + '/config/amazon_s3.yml'
  s3_config = YAML.load_file(s3_config_path)[ENV['RAILS_ENV']]
  AWS::S3::Base.establish_connection!(
  :access_key_id     => s3_config["access_key_id"],
  :secret_access_key => s3_config["secret_access_key"],
  :server            => s3_config["server"],
  :port              => s3_config["port"],
  :use_ssl           => s3_config["use_ssl"]
  )
  s3_config
end

def try_to_upload try_count=0
  begin
    upload_files()
  rescue => m
    # If something goes wrong (usally due to timeout of the connection to Amazon), log the error, set a counter, wait a few seconds, and try again. 
    # If things goes wrong more than 10 times, write an error file to the log directory, and break out of the task.
    rake_log do |log|
      log.info "Error message:\n#{m}"
    end
    if try_count > 9
      File.open(File.join(RAILS_ROOT, 'log', 'tmpError'),'a+') do |file|
        file.puts "Error in #{__FILE__}:\n#{m}\n\n"
      end
      FileUtils.rm_f(File.join(RAILS_ROOT, 'log', 'tmpS3Uploading'))
      removing_uploaded_files
    else
      try_count += 1
      msg try_count
      sleep 30
      try_to_upload(try_count)
    end
  end
end

def upload_files
  File.new(File.join(RAILS_ROOT, 'log', 'tmpS3Uploading'),'w')
  index = S3Upload.send do |file|
    msg "Uploading file: #{file.id}"
  end
  FileUtils.rm_f(File.join(RAILS_ROOT, 'log', 'tmpS3Uploading'))
  File.new(File.join(RAILS_ROOT, 'log', 'tmpS3Removing'),'w')
  rake_log do |log|
    log.info "A total of #{index} files was uploaded to S3 on #{Time.now}"
  end
  sleep 60
  # Wait 60 seconds before removing uploaded files. Should be enough for no race conditions
  removing_uploaded_files()
end

def removing_uploaded_files
  count = AbstractFile.remove_annonymous()
  msg "#{count} temporary files removed"
  loop do
    unless File.exist? File.join(RAILS_ROOT, 'log', 'tmpS3Uploading')
      index = S3Upload.remove do |file|
        msg "Removing file: #{file.id}"
      end
      FileUtils.rm_f(File.join(RAILS_ROOT, 'log', 'tmpS3Removing'))
      rake_log do |log|
        log.info "A total of #{index} files was removed on #{Time.now}"
      end
      break
    end
    rake_log do |log|
      log.info "The upload task was not finished on #{Time.now}. Waiting for 10 minutes before next attempt..."
    end
    sleep 600
  end
end

def db_create env_name
  task_info "Started install task on environment #{env_name}"

  Dir.mkdir 'log' unless File.exist? 'log'
  config =  database_configuration[env_name]
  puts
  if config == nil
    puts "Task Failure! Uknown environment #{env_name}. Unable to proceed"
  else
    puts "Creating database #{config['database']} ....."
    create_db(config)
  end
  task_info "Finished install task on environment #{env_name}"
end

def db_clobber env_name
  task_info "Started clobber task on environment #{env_name}"

  config =  database_configuration[env_name]
  if config == nil
    puts "Task Failure! Uknown environment #{env_name}. Unable to proceed"
  else
    puts "Dropping database #{config['database']} ....."
    drop_db(config)
  end

  task_info "Finished clobber task on environment #{env_name}"
end


# make db function
def task_info(msg)
  puts
  puts ' ------------------------------------------------------' 
  puts " ---- #{msg} --"
  puts ' ------------------------------------------------------' 
  puts
end

# -------------------- 
# Mysql binary calls
# -------------------- 

def drop_db(conf)
  IO.popen(mysql(conf, false), 'w') do |io|
    io << "drop database #{conf['database']}"
  end
end


def drop_tables(conf)
  tablelist = []
  IO.popen(mysql(conf, true), 'w+') do |io|
    io.puts "show tables;;"
    io.close_write
    io.each do |line|
      line = line.chomp
      next if line.empty?
      tablelist.push(line)
    end
  end
  puts "Dopping tables:"
  tablelist.each do |tablename|
    puts "drop table #{tablename};"
  end
  IO.popen(mysql(conf, true), 'w') do |io|
    tablelist.each do |tablename|
      io.puts "drop table #{tablename};"
    end
  end
  puts "Tables are dropped sucessfully"
end

def create_db(conf)
  IO.popen(mysql(conf, false), 'w') do |io|
    io << "create database #{conf['database']}"
  end
end


def mysql(conf, use_db)
  mysql = ['mysql']
  mysql << "-u#{conf['username']}"
  mysql << "-p#{conf['password']}" if conf['password']
  mysql << "-h#{conf['host']}" if conf['host']
  mysql << "-B"
  mysql << "--skip-column-names"
  mysql << "--line-numbers"
  #mysql << "--disable-pager"
  mysql << "--force"
  #mysql << "--tee=log/mysqlout.log"
  mysql << conf['database'] if use_db
  return mysql.join(' ')
end


def database_configuration
    result = File.read "#{RAILS_ROOT}/config/database.yml"
      result.strip!
      config_file = YAML::load(ERB.new(result).result)
    
  #YAML::load(ERB.new(IO.read(File.join(File.dirname("../"), 'config', 'database.yml'))).result)
  # YAML::load(ERB.new(result).result)
end

def rake_log
  log = Logger.new(File.open(File.join(RAILS_ROOT, 'log', 'admin.log'), File::WRONLY | File::APPEND | File::CREAT))
  log.level = Logger::INFO
  yield log
  log.close
end

