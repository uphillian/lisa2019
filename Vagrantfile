# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.define "web" do |web|
    web.vm.box = "centos/7"
    web.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "docker-apache.yml"
      ansible.become = true
    end
    web.vm.network "private_network", ip: "192.168.0.2"
  end

  config.vm.define "browser" do |browser|
    browser.vm.box = "centos/7"
    browser.vm.network "private_network", ip: "192.168.0.20"
  end
  config.vm.define "getip" do |getip|
    getip.vm.box = "centos/7"
    getip.vm.network "private_network", ip: "192.168.0.200"
    getip.vm.provision "ansible" do |ansible|
      ansible.playbook = "playbook.yml"
    end
  end
end
