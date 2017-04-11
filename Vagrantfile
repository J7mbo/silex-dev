# -*- mode: ruby -*-
# vi: set ft=ruby :

# Plugins required for each dev for this to work:
required_plugins = %w( vagrant-hostmanager )
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
end

# Start vagrant configuration
Vagrant.configure(2) do |config|

  # We're using Ubuntu 16.04
  config.vm.box = "geerlingguy/ubuntu1604"

  # Default SSH credentials
  config.ssh.username = "vagrant"
  config.ssh.password = "vagrant"

  # Set up settings specific to the virtual machine
  config.vm.provider :virtualbox do |vb|

      # Give the poor thing some memory...
      vb.memory = 1024

      # Allow Vagrant to access host's internet data
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]

      # Allow X11 forwarding (xclip needs it for headless servers)
      vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
  end

  # To use ssh from this box, needs to forwarded to host
  config.ssh.forward_agent=true
  config.vm.network "forwarded_port", guest: 22, host:2333, host_ip: "0.0.0.0"

  config.vm.provision :shell do |shell|
    shell.inline = "touch $1 && chmod 0440 $1 && echo $2 > $1"
    shell.inline = "(grep -q 'mesg n' /root/.profile && sed -i '/mesg n/d' /root/.profile && echo 'Ignore the previous error, fixing this now...') || exit 0;"
    shell.args = %q{/etc/sudoers.d/root_ssh_agent "Defaults    env_keep += \"SSH_AUTH_SOCK\""}
  end

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
      if hostname = (vm.ssh_info && vm.ssh_info[:host])
          `vagrant ssh -c "hostname -I"`.split()[1]
      end
  end

  # Begin configuring with shell script
  config.vm.define "silex" do|silex|
    silex.vm.hostname = "silex.local"
    silex.vm.network "private_network", type: "dhcp"

    silex.vm.provision :shell, path: "vagrant/base_install.sh"
    silex.vm.provision :shell, path: "vagrant/install.sh", privileged: false
  end
end
