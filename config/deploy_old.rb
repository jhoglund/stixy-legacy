# =============================================================================
# ENGINE YARD REQUIRED VARIABLES
# =============================================================================
# You must always specify the application and repository for every recipe. The
# repository must be the URL of the repository you want this recipe to
# correspond to. The deploy_to path must be the path on each machine that will
# form the root of the application path.

set :keep_releases, 5
set :application,   'stixy'
#set :repository,    'https://stixy.svn.ey01.engineyard.com/stixy/trunk/src/railsapp'
set :repository,     'git@github.com:jhoglund/stixy.git'
#set :scm_username,  'deploy'
#set :scm_password,  '3at5lbs'
set :user,          'stixy'
set :password,      '4f0NmjCkR'
set :deploy_to,     "/data/#{application}"
set :deploy_via,    :remote_cache
#set :deploy_via,    :export
set :mongrel_monit_group,   'mongrel'
set :extra_monit_group,   'extra'
set :scm,           :git
set :uploading_to_s3_file_path, "#{shared_path}/log/tmpS3Uploading"
set :removing_uploaded_file_path, "#{shared_path}/log/tmpS3Removing"
set :test_depend, "#{shared_path}/log/production.log"

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false

# default_run_options[:pty] = true # required for svn+ssh://

# Before anything, see so files are not currently being uploaded to S3
# depend :remote, :file_not_exist, test_depend
#depend :remote, :file_not_exist, uploading_to_s3_file_path
#depend :remote, :file_not_exist, removing_uploaded_file_path

# =============================================================================
# ROLES
# =============================================================================
# You can define any number of roles, each of which contains any number of
# machines. Roles might include such things as :web, or :app, or :db, defining
# what the purpose of each machine is. You can also specify options that can
# be used to single out a specific subset of boxes in a particular role, like
# :primary => true. 
task :production do
   
  role :web, '65.74.139.2:8411'
  role :app, '65.74.139.2:8411'
  role :db, '65.74.139.2:8411', :primary => true
   
  set :environment_database, Proc.new { production_database }
end

task :staging do
  
  set :environment_database, Proc.new { stage_database }
end

# =============================================================================
# Any custom after tasks can go here.
after "deploy:symlink_configs", "stixy_custom"
task :stixy_custom, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
  run <<-CMD
  CMD
end
# =============================================================================
# TASKS
# Don't change unless you know what you are doing!
after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code","deploy:symlink_configs"
# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"

# =============================================================================  
namespace :mongrel do
  desc <<-DESC
  Start Mongrel processes on the app server.  This uses the :use_sudo variable to determine whether to use sudo or not. By default, :use_sudo is
  set to true.
  DESC
  task :start, :roles => :app do
    sudo "/usr/bin/monit start all -g #{mongrel_monit_group}"
    sudo "/usr/bin/monit start all -g #{extra_monit_group}"
  end

  desc <<-DESC
  Restart the Mongrel processes on the app server by starting and stopping the cluster. This uses the :use_sudo
  variable to determine whether to use sudo or not. By default, :use_sudo is set to true.
  DESC
  task :restart, :roles => :app do
    sudo "/usr/bin/monit restart all -g #{mongrel_monit_group}"
    sudo "/usr/bin/monit restart all -g #{extra_monit_group}"
  end

  desc <<-DESC
  Stop the Mongrel processes on the app server.  This uses the :use_sudo
  variable to determine whether to use sudo or not. By default, :use_sudo is
  set to true.
  DESC
  task :stop, :roles => :app do
    sudo "/usr/bin/monit stop all -g #{mongrel_monit_group}"
    sudo "/usr/bin/monit stop all -g #{extra_monit_group}"
  end
  
  desc "Get the status of your mongrels"
  task :status, :roles => :app do
    @monit_output ||= { }
    sudo "/usr/bin/monit status" do |channel, stream, data|
      @monit_output[channel[:server].to_s] ||= [ ]
      @monit_output[channel[:server].to_s].push(data.chomp)
    end
    @monit_output.each do |k,v|
      puts "#{k} -> #{'*'*55}"
      puts v.join("\n")
    end
  end
end

# =============================================================================
namespace :nginx do 
  desc "Start Nginx on the app server."
  task :start, :roles => :app do
    sudo "/etc/init.d/nginx start"
  end

  desc "Restart the Nginx processes on the app server by starting and stopping the cluster."
  task :restart , :roles => :app do
    sudo "/etc/init.d/nginx restart"
  end

  desc "Stop the Nginx processes on the app server."
  task :stop , :roles => :app do
    sudo "/etc/init.d/nginx stop"
  end

  desc "Tail the nginx logs for this environment"
  task :tail, :roles => :app do
    run "tail -f /var/log/engineyard/nginx/vhost.access.log" do |channel, stream, data|
      puts "#{channel[:server]}: #{data}" unless data =~ /^10\.[01]\.0/ # skips lb pull pages
      break if stream == :err    
    end
  end
end

# =============================================================================
# after "deploy:update_code","ferret:symlink_configs" # uncomment this to hook up configs by default
# after "deploy:symlink","ferret:restart"             # uncomment this to restart ferret drb after deploy
namespace :ferret do
  desc "After update_code you want to symlink the index and ferret_server.yml file into place"
  task :symlink_configs, :roles => :app, :except => {:no_release => true} do
    run <<-CMD
      cd #{release_path} &&
      ln -nfs #{shared_path}/config/ferret_server.yml #{release_path}/config/ferret_server.yml &&
      ln -nfs #{shared_path}/index #{release_path}/index
    CMD
  end
  [:start,:stop,:restart].each do |op|
    task op, :roles => :app, :except => {:no_release => true} do
      sudo "/usr/bin/monit #{op} all -g ferret_#{application}"
    end
  end
end

# =============================================================================
namespace(:deploy) do  
  task :symlink_configs, :roles => :app, :except => {:no_symlink => true} do
    run <<-CMD
      cd #{release_path} &&
      ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml &&
      ln -nfs #{shared_path}/public/images/pending_storage #{release_path}/public/images/pending_storage &&
      ln -nfs #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/mongrel_cluster.yml
    CMD
  end
  
  desc "Long deploy will throw up the maintenance.html page and run migrations 
        then it restarts and enables the site again."
  task :long do
    transaction do
      update_code
      web.disable
      symlink
      migrate
    end
  
    restart
    web.enable
  end

  desc "Restart the Mongrel processes on the app server by calling restart_mongrel_cluster."
  task :restart, :roles => :app do
    mongrel.restart
  end

  desc "Start the Mongrel processes on the app server by calling start_mongrel_cluster."
  task :spinner, :roles => :app do
    mongrel.start
  end

  desc "Tail the Rails production log for this environment"
  task :tail_production_logs, :roles => :app do
    run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:server]} -> #{data}" 
      break if stream == :err    
    end
  end
end


# =============================================================================
set :production_database,'stixy_prod'
set :stage_database, 'stixy_stage'
set :sql_user, 'stixy_db'
set :sql_pass, 'l9h3cyz7'
set :sql_host, 'mysql50-1'

namespace :db do
  task :backup_name do
    now = Time.now
    run "mkdir -p #{shared_path}/db_backups"
    backup_time = [now.year,now.month,now.day,now.hour,now.min,now.sec].join('-')
    set :backup_file, "#{shared_path}/db_backups/#{environment_database}-snapshot-#{backup_time}.sql"
  end
  
  desc "Clone Production Database to Staging Database."
  task :clone_prod_to_stage, :roles => :db, :only => { :primary => true } do
    backup_name
    on_rollback { run "rm -f #{backup_file}" }
    run "mysqldump --add-drop-table -u #{sql_user} -h #{sql_host} -p#{sql_pass} #{production_database} > #{backup_file}"
    run "mysql -u #{sql_user} -p#{sql_pass} -h #{sql_host} #{stage_database} < #{backup_file}"
    run "rm -f #{backup_file}"
  end
  
  desc "Backup your Database to #{shared_path}/db_backups"
  task :dump, :roles => :db, :only => {:primary => true} do
    backup_name
    run "mysqldump --add-drop-table -u #{sql_user} -h #{sql_host} -p#{sql_pass} #{environment_database} | bzip2 -c > #{backup_file}.bz2"
  end
end

