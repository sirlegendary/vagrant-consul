sudo cat << EOF > /etc/consul.d/config.hcl
# agent-server-secure.hcl
# Data Persistence
data_dir = "/etc/data/consul"
# Logging
log_level = "DEBUG"
# Enable service mesh
connect {
  enabled = true
}

datacenter = "local"
retry_join = ["10.0.0.2","10.0.0.3","10.0.0.4"]
# Addresses and ports
addresses {
  grpc = "$2"
  https = "0.0.0.0"
  dns = "0.0.0.0"
  http = "0.0.0.0"
}
bind_addr = "$2"
ports {
  grpc_tls  = 8502
  http  = 8500
  https = 8443
  dns   = 8600
}
# DNS recursors
recursors = ["1.1.1.1"]
# Disable script checks
enable_script_checks = false
# Enable local script checks
enable_local_script_checks = true

# bootstrap_expect = $3
EOF

rm -f /vagrant/tls/consul/local-server-consul-0.pem /vagrant/tls/consul/local-server-consul-0-key.pem
sudo rm -rf /etc/consul.d/tls.hcl 
# mkdir /vagrant/tls/
# mkdir /vagrant/tls/consul/
# cd /vagrant/tls/consul/;[ -e /vagrant/tls/consul/consul-agent-ca.pem ] || consul tls ca create
# cd /vagrant/tls/consul/;[ -e /vagrant/tls/consul/consul-agent-ca-key.pem ] || consul tls ca create
# mkdir /etc/consul.d/tls/
# cd /etc/consul.d/tls; consul tls cert create -dc local -server -ca /vagrant/tls/consul/consul-agent-ca.pem -key /vagrant/tls/consul/consul-agent-ca-key.pem

sudo chown consul:consul /etc/consul.d/config.hcl
# sudo chown -R consul:consul /etc/consul.d/tls

mv /etc/consul.d/consul.service /etc/systemd/system/consul.service

sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul

