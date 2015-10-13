#!/bin/bash
cd /srv
export JRUBY_OPTS=--server -J-Xms2048m -J-Xmx2048m -J-XX:+UseConcMarkSweepGC -J-XX:-UseGCOverheadLimit -J-XX:+CMSClassUnloadingEnabled
puma -C ./config/puma.rb
nginx