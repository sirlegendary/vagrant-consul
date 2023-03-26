images :=	base \
			consul \
			consul_server \
			consul_client 

all:
	$(foreach image,$(images),\
		$(MAKE) build image=$(image);)
build:
	echo $@
	packer build -force -only $(image).vagrant.base . 

cleanup:
	$(foreach image,$(images),\
		vagrant box remove $(image); vagrant box remove ./box/$(image)/package.box)