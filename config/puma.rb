#!/usr/bin/env puma

# start puma with:
# puma -C ./config/puma.rb

#application_path = '.'
railsenv = 'production'
#directory application_path
environment railsenv
daemonize true
#pidfile "/srv/pids/puma-production.pid"
#state_path "#{application_path}/tmp/pids/puma-#{railsenv}.state"
# stdout_redirect "/var/log/nginx/puma-#{railsenv}.stdout.log", "/var/log/nginx/puma-#{railsenv}.stderr.log"
threads 0, 16
bind 'tcp://0.0.0.0:3000'