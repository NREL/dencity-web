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
