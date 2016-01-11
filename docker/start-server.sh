#!/bin/bash
cd /srv
export JRUBY_OPTS=--server 
puma -C ./config/puma.rb
nginx
