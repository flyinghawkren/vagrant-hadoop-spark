# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'ipaddr'

vm_cfg = YAML.load_file("provisioning/vm_config.yml")

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/xenial64"

  # Use the ipaddr library to calculate the netmask of a given network
  net = IPAddr.new vm_cfg['public_network']
  netmask = net.inspect().split("/")[1].split(">")[0]

  # Bring up the Devstack ovsdb/ovn-northd node on Virtualbox
  config.vm.define "master" do |master|
    master.vm.host_name = vm_cfg['master']['hostname']
    master.vm.network "private_network", ip: vm_cfg['master']['ipv4'], netmask: netmask, nic_type: "virtio"
    master.vm.provision "shell", path: "provisioning/setup-hosts.sh", privileged: true,
      :args => "#{vm_cfg['master']['ipv4']} #{vm_cfg['master']['hostname']} #{vm_cfg['node1']['ipv4']} #{vm_cfg['node1']['hostname']} #{vm_cfg['node2']['ipv4']} #{vm_cfg['node2']['hostname']}"
    master.vm.provision "shell", path: "provisioning/setup-master.sh", privileged: true,
      :args => "#{vm_cfg['master']['ipv4']} #{vm_cfg['master']['hostname']} #{vm_cfg['node1']['ipv4']} #{vm_cfg['node1']['hostname']} #{vm_cfg['node2']['ipv4']} #{vm_cfg['node2']['hostname']}"
    master.vm.provider "virtualbox" do |vb|
       vb.name = 'hadoop-master'
       vb.memory = vm_cfg['master']['memory']
       vb.cpus = vm_cfg['master']['cpus']
       vb.customize [
           'modifyvm', :id,
           '--nicpromisc3', "allow-all"
          ]
       vb.customize [
           "guestproperty", "set", :id,
           "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000
          ]
    end
  end

  config.vm.provider "virtualbox" do |v|
    v.default_nic_type = "82543GC"
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    v.customize ["modifyvm", :id, "--nictype1", "virtio"]
  end
end