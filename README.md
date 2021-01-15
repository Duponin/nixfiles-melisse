# Nixfiles

## Install a VM

* add network to VM
  * `ip a add 2a0c:e300:<IID> dev <dev>`
  * `ip r add default via 2a0c:e300:12::190 dev <dev>`
  * `echo "nameserver 2a0c:e300::100" >> /etc/resolv.conf`
* Launch install script
  * `curlhttps://git.locahlo.st/chatons/nixfiles/-/raw/master/scripts/install.sh | bash -s <disk> <hostname>`

The VM should be accessible via SSH.
