# -*- mode: ruby -*-
# vi: set ft=ruby :

CONSUL_SERVER_NUMER = 3
CONSUL_CLIENT_NUMER = 2
Vagrant.configure(2) do |config|
  # Increase memory for Virtualbox
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
  end
  (0..CONSUL_SERVER_NUMER-1).each do |i|
    config.vm.define "consul_server-#{i}" do |consul|
      consul.vm.box = "consul_server" # 22.04 LTS, Jammy
      consul.vm.hostname = "consul-server-#{i}"
      consul.vm.provision "shell" do |shell|
        shell.path = "consul.sh"
        shell.args = [i, "10.0.0.#{i + 2}", CONSUL_SERVER_NUMER]
        shell.privileged = true
      end
      consul.vm.post_up_message = "login to consul on port 8500"
      # Expose the consul api and ui to the host
      consul.vm.network "forwarded_port", guest: 8500, host: 8500, auto_correct: true, host_ip: "127.0.0.1"
      consul.vm.network "forwarded_port", guest: 8443, host: 8443, auto_correct: true, host_ip: "127.0.0.1"
      consul.vm.network "private_network", ip: "10.0.0.#{i + 2}", virtualbox__intnet: "consul"
    end
  end
  (0..CONSUL_CLIENT_NUMER-1).each do |i|
    config.vm.define "consul_client-#{i}" do |consul|
      consul.vm.box = "consul_client" # 22.04 LTS, Jammy
      consul.vm.hostname = "consul-client-#{i}"
      consul.vm.provision "shell" do |shell|
        shell.path = "consul_client.sh"
        shell.args = [i, "10.0.0.#{i + 6}", CONSUL_CLIENT_NUMER]
        shell.privileged = true
      end
      consul.vm.post_up_message = "login to consul on port 8500"
      # Expose the consul api and ui to the host
      consul.vm.network "forwarded_port", guest: 8500, host: 8500, auto_correct: true, host_ip: "127.0.0.1"
      consul.vm.network "forwarded_port", guest: 8443, host: 8443, auto_correct: true, host_ip: "127.0.0.1"
      consul.vm.network "private_network", ip: "10.0.0.#{i + 6}", virtualbox__intnet: "consul"
    end
  end
end
