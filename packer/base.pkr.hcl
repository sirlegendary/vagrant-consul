source "vagrant" "base" {
  communicator = "ssh"
  add_force    = true
  provider     = "virtualbox"

}

build {
  name = "base"
  source "source.vagrant.base" {
    source_path = "bento/ubuntu-22.04"
    output_dir  = "./box/base"
  }
  provisioner "shell" {
    inline = [
      "set -x",
      "df -H",
      "sudo apt-get update",
      "sudo apt-get install -y unzip jq"
    ]
  }
  post-processor "shell-local" {
    inline = ["vagrant box add base --force --name base ./box/base/package.box"]
  }
}


build {
  name = "consul"
  source "source.vagrant.base" {
    source_path = "./box/base/package.box"
    box_name    = "base"
    output_dir  = "./box/consul"
  }
  provisioner "shell" {
    inline = [
      "curl https://releases.hashicorp.com/consul/1.15.1/consul_1.15.1_linux_amd64.zip -o /tmp/consul.zip",
      "cd /tmp && unzip /tmp/consul.zip",
      "sudo mv /tmp/consul /usr/local/bin/consul",
      "sudo chmod 0755 /usr/local/bin/consul",
      "sudo mkdir /etc/data",
      "sudo mkdir /etc/data/consul",
      "sudo mkdir /etc/consul.d",
      "sudo chmod 0755 /etc/data/consul",
      "sudo chmod 0755 /etc/consul.d",
      "sudo adduser --system --group consul || true",
      "sudo chown consul:consul /usr/local/bin/consul",
      "sudo chown consul:consul /etc/data/consul"
    ]
  }
  provisioner "file" {
    destination = "/tmp/gossip-encription.hcl"
    content     = <<EOF
  encrypt = "SUwx06yZnIDDQmZOYFQrkpMUNH5MjVZQZE0cUWkU8mE="
  EOF
  }
  provisioner "file" {
    destination = "/tmp/consul.service"
    content     = <<EOF
[Unit]
Description=consul

[Service]
ExecStart=/usr/local/bin/consul agent -node=$${HOSTNAME} -config-dir=/etc/consul.d
User=consul
Group=consul
LimitMEMLOCK=infinity
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK

[Install]
WantedBy=multi-user.target
      EOF
  }
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/consul.service /etc/consul.d/consul.service",
      "sudo mv /tmp/gossip-encription.hcl /etc/consul.d/gossip-encription.hcl",
      "sudo chmod 664 /etc/consul.d/consul.service",
      "sudo chown consul:consul /etc/consul.d/gossip-encription.hcl"

    ]
  }
  post-processor "shell-local" {
    inline = ["vagrant box add consul --force --name base ./box/consul/package.box"]
  }
}

build {
  name = "consul_server"
  source "source.vagrant.base" {
    source_path = "./box/consul/package.box"
    box_name    = "consul"
    output_dir  = "./box/consul_server"
  }
  provisioner "file" {
    destination = "/tmp/tls.hcl"
    content     = <<EOF
tls = {
    defaults = {
        ## TLS Encryption (requires cert files to be present on the server nodes)
        ca_file   = "/vagrant/tls/consul/consul-agent-ca.pem"
        cert_file = "/etc/consul.d/tls/local-server-consul-0.pem"
        key_file  = "/etc/consul.d/tls/local-server-consul-0-key.pem"
        verify_incoming        = false
        verify_outgoing        = true
    }
    internal_rpc = {
        verify_incoming        = true
        verify_server_hostname = true
    }
}
      EOF
  }
  provisioner "file" {
    destination = "/tmp/server.hcl"
    content     = <<EOF
## Server specific configuration for local
server = true

datacenter = "local"
client_addr = "0.0.0.0"
retry_join = ["10.0.0.2","10.0.0.3","10.0.0.4"]
## UI configuration (1.9+)
ui_config {
  enabled = true
}
auto_encrypt {
   allow_tls = true
}

      EOF
  }
  provisioner "file" {
    destination = "/tmp/acl.hcl"
    content     = <<EOF
## ACL configuration
acl = {
  enabled = false
  default_policy = "allow"
  enable_token_persistence = true
  enable_token_replication = true
  down_policy = "extend-cache"
}
      EOF
  }
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/tls.hcl /etc/consul.d/tls.hcl",
      "sudo mv /tmp/server.hcl /etc/consul.d/server.hcl",
      "sudo mv /tmp/acl.hcl /etc/consul.d/acl.hcl",
      "sudo chown consul:consul /etc/consul.d/tls.hcl",
      "sudo chown consul:consul /etc/consul.d/server.hcl",
      "sudo chown consul:consul /etc/consul.d/acl.hcl"

    ]
  }
  post-processor "shell-local" {
    inline = ["vagrant box add consul_server --force --name base ./box/consul_server/package.box"]
  }
}

build {
  name = "consul_client"
  source "source.vagrant.base" {
    source_path = "./box/consul/package.box"
    box_name    = "consul"
    output_dir  = "./box/consul_client"
  }
  provisioner "file" {
    destination = "/tmp/tls.hcl"
    content     = <<EOF
tls = {
    defaults = {
        ## TLS Encryption (requires cert files to be present on the server nodes)
        ca_file   = "/vagrant/tls/consul/consul-agent-ca.pem"
        cert_file = "/etc/consul.d/tls/local-client-consul-0.pem"
        key_file  = "/etc/consul.d/tls/local-client-consul-0-key.pem"
        verify_incoming        = false
        verify_outgoing        = true
    }
    internal_rpc = {
        verify_incoming        = true
        verify_server_hostname = true
    }
}
      EOF
  }
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/tls.hcl /etc/consul.d/tls.hcl",
      "sudo chown consul:consul /etc/consul.d/tls.hcl"
    ]
  }
  post-processor "shell-local" {
    inline = ["vagrant box add consul_client --force --name base ./box/consul_client/package.box"]
  }
}