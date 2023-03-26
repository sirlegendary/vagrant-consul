function build(){
    packer build -force -only $1.vagrant.base .; vagrant box add $1 --force --name base ./box/$1/package.box
}

#build base
build consul
build consul_server
build consul_client
