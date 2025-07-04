server "174.143.253.83", :app, :web, :db, :primary => true


set :application, "application"
set :repository, 'git@github.com:jhoglund/stixy.git'
set :user, 'stixy'
set :stage, 'staging'
#set :branch, 'helmdesk_integration'

default_run_options[:pty] = true
set(:deploy_to) {"/home/#{user}/#{application}/#{stage}/"}  # must be a proc, cause stage is defined late
set(:rails_env) {"#{stage}"}
set :deploy_via, :remote_cache
set :use_sudo, false
set :scm,           :git
set :copy_remote_dir, "/home/#{user}/tmp"

namespace :deploy do
    desc <<-DESC
    Restart all the Mongrel processes on the app server.
    DESC
    task :restart, :roles => :app do
        run "mongrel_cluster_ctl restart"
    end
    desc <<-DESC
    Start all the Mongrel processes on the app server.
    DESC
    task :start, :roles => :app do
        run "mongrel_cluster_ctl start"
    end
    desc <<-DESC
    Stop all the Mongrel processes on the app server.
    DESC
    task :stop, :roles => :app do
        run "mongrel_cluster_ctl stop"
    end
end

after "deploy", "deploy:cleanup"

# namespace :deploy do
#   task :start, :roles => :app do
#     run "touch #{current_release}/tmp/restart.txt"
#   end
# 
#   task :stop, :roles => :app do
#     # Do nothing.
#   end
# 
#   desc "Restart Application"
#   task :restart, :roles => :app do
#     run "touch #{current_release}/tmp/restart.txt"
#   end
# end

