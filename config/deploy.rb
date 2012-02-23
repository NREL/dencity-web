require "bundler/capistrano"

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :application, "bemscape"
set :user, "railsdeploy"
set :scm, :subversion
set :scm_username, "railsdeploy"
set :scm_password, proc { Capistrano::CLI.password_prompt("Webdev-Mirror SVN Password: ") }
set :repository,  "https://cbr.nrel.gov/webdev-mirror/svn/bemscape.nrel.gov/trunk"
set :deploy_to, "/var/www/rails/bemscape"
set :use_sudo, true
set :app_server, :passenger

default_run_options[:pty] = true  #needed because of the no tty for sudo

#e-watts DEV server (running in production mode)
role :web, "e-watts.nrel.gov"                          # Your HTTP server, Apache/etc
role :app, "e-watts.nrel.gov"                          # This may be the same as your `Web` server
role :db,  "e-watts.nrel.gov", :primary => true        # This is where Rails migrations will run
role :db,  "e-watts.nrel.gov"

#rorsrv PROD server
#role :web, "rorsrv-prod-01.nrel.gov"                          # Your HTTP server, Apache/etc
#role :app, "rorsrv-prod-01.nrel.gov"                          # This may be the same as your `Web` server
#role :db,  "rorsrv-prod-01.nrel.gov", :primary => true # This is where Rails migrations will run
#role :db,  "rorsrv-prod-01.nrel.gov"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  
  system("#{try_sudo} chgrp apache #{Rails.root}/public/tmpdata/")
end

namespace :rake do
  task :download_data do

  end
end

