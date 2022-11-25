# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config| 

config.vm.define "backup" do |backup|
  config.vm.box = 'centos/7'

  backup.vm.host_name = 'backup'
  backup.vm.network "private_network", ip: "192.168.56.240"

  backup.vm.disk :disk, size: "2GB", name: "backup_1"

  backup.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end
  end
end
Vagrant.configure("2") do |config| 

  config.vm.define "client" do |client|
    config.vm.box = 'centos/7'

    client.vm.host_name = 'client'
    client.vm.network "private_network", ip: "192.168.56.241"
  
    client.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end
    end
end

