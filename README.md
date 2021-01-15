# Nixfiles

## Install a VM

1. add network to VM
  1. `ip a add 2a0c:e300:<IID> dev <dev>`
  2. `ip r add default via 2a0c:e300:12::190 dev <dev>`
  3. `echo "nameserver 2a0c:e300::100" >> /etc/resolv.conf`
2. Launch install script
  1. `curl
https://git.locahlo.st/chatons/nixfiles/-/raw/master/scripts/install.sh | bash
-s <disk> <hostname>`

The VM should be accessible via SSH.
