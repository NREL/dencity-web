#
# Cookbook Name:: dencity
# Recipe:: default
#
# Copyright (C) 2015 Nicholas Long
#
# All rights reserved - Do Not Redistribute
#

include_recipe "docker"

# Add users to the docker group
%w(vagrant).each do |u|
  group "docker" do
    members u
    append true

    only_if "getent passwd #{u}"
  end
end

directory '/var/data/solr' do
  owner 'vagrant'
  group 'docker'
end

# install the solr container
docker_container 'makuk66/docker-solr' do
  container_name 'dencity-solr'
  detach true
  port '8983:8983'
  # env 'SETTINGS_FLAVOR=local'
  volume '/var/data/solr:/docker-storage'
end

directory '/var/data/mongodb' do
  owner 'vagrant'
  group 'docker'
end

# install the database
# #docker run -d -p 27017:27017 -v <db-dir>:/data/db --name mongodb
docker_container 'dockerfile/mongodb' do
  container_name 'dencity-db'
  detach true
  port '27017:27017'
  volume '/var/data/mongodb:/docker-storage'
end

# # build the docker container for the web application
docker_image 'nllong/dencity-web' do
  source '/var/data/web
'
  action :build_if_missing
end

# install the database
#docker run -d -p 27017:27017 -v <db-dir>:/data/db --name mongodb
docker_container 'nllong/dencity-web' do
  container_name 'dencity-web'
  link ['dencity-db']
  detach true
  port '80:80'
  volume '/mnt/docker:/docker-storage'
end