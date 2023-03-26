# vagrant-consul
Spins up 1 consul server &amp; 2 client

## Prerequisite

- vagrant installed
- packer installed
- consul

## Usage

Build the vagrant boxes using packer

```bash
cd packer
packer build -force -only base.vagrant.base .
make
```

`This may take some time`

Now create your machines by running `vagrant up` in the root directory.

```bash
cd ..
vagrant up
```

For logs

```bash
vagrant ssh consul_(server|client)
journalctl -u consul
```
