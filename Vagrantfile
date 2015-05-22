# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = '2'

Vagrant.require_version '>= 1.5.0'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = 'dencity-berkshelf'

  config.vm.box = 'chef/centos-6.6'

  config.omnibus.chef_version = :latest

  config.berkshelf.enabled = true

  config.vm.network 'private_network', ip: '193.168.50.10'

  config.vm.synced_folder '.', '/var/data/web', type: 'nfs'

  config.vm.provider 'virtualbox' do |vb|
    vb.customize ['modifyvm', :id, '--memory', '2048', '--cpus', 2]
  end

  config.vm.provision 'chef_solo' do |chef|
    chef.cookbooks_path = 'chef/cookbooks'
    chef.roles_path = 'chef/roles'

    chef.add_role 'dencity_base'
  end
end
