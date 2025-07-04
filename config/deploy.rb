require "eycap/recipes"
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
set :monit_group,   'mongrel'
#set :extra_monit_group,   'extra'
set :scm,           :git
# set :uploading_to_s3_file_path, "#{shared_path}/log/tmpS3Uploading"
# set :removing_uploaded_file_path, "#{shared_path}/log/tmpS3Removing"
set :test_depend, "#{shared_path}/log/production.log"

# comment out if it gives you trouble. newest net/ssh needs this set.
ssh_options[:paranoid] = false

set :production_database,'stixy_prod'
set :production_dbhost,'mysql50-1'
set :staging_database, 'stixy_stage'
set :staging_dbhost,'mysql50-1'
set :sql_user, 'stixy_db'
set :sql_pass, 'l9h3cyz7'
set :sql_host, 'mysql50-1'

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
  set :rails_env, 'production'
  
  role :web, '65.74.139.2:8411'
  role :app, '65.74.139.2:8411', :mongrel => true, :memcached => true
  role :db, '65.74.139.2:8411', :primary => true
   
  set :environment_database, Proc.new { production_database }
  set :environment_dbhost, Proc.new { production_dbhost }
end

task :staging do  
  set :environment_database, Proc.new { staging_database }
  set :environment_dbhost, Proc.new { staging_dbhost }
end

# =============================================================================
# Any custom after tasks can go here.
# after "deploy:symlink_configs", "stixy_custom"
# task :stixy_custom, :roles => :app, :except => {:no_release => true, :no_symlink => true} do
#   run <<-CMD
#   ln -nfs #{shared_path}/public/images/pending_storage #{release_path}/public/images/pending_storage
#   CMD
# end
# =============================================================================
# TASKS
# Don't change unless you know what you are doing!
after "deploy", "deploy:cleanup"
after "deploy:migrations", "deploy:cleanup"
after "deploy:update_code","deploy:symlink_configs"
# uncomment the following to have a database backup done before every migration
# before "deploy:migrate", "db:dump"

# after "deploy:update_code","ferret:symlink_configs" # uncomment this to hook up configs by default
# after "deploy:symlink","ferret:restart"             # uncomment this to restart ferret drb after deploy
# =============================================================================
