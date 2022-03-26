# Nixfiles
## Install a VM

- Add network to VM **(!!!ONLY NEEDED IF NO DHCP IS AVAILABLE!!!)**
  - `ip a add 2a0c:e300:12::XXXX/48 dev <dev>`
  - `ip a add 185.233.102.XXX dev <dev>`
  - `ip r add default via 2a0c:e300:12::190 dev <dev>`
  - `ip r add default via 185.233.102.190 dev <dev>`
  - `echo "nameserver 2a0c:e300::100" > /etc/resolv.conf`
- Launch install script **script is outdated**
  - `curl https://git.locahlo.st/chatons/nixfiles/-/raw/master/scripts/install.sh | bash -s <disk> <hostname>`
    - Where `<disk>` is the target disk (generally `/dev/sda`)
    - Where `<hostname>` the target hostname
    - **NOTE:** target **MUST** has a valid `configuration.nix` under `configuration/hosts/<hostname>/` in this repository

The VM should be accessible via SSH after reboot.

## `nix-shell` and dependencies

So tools are needed to perform actions such secrets encryption or deployements.
If you have [`Nix`](https://nixos.org/guides/install-nix.html) installed on your machine you don't need anything else, any dependencies will be installed by entering in the `nix-shell` (**WARNING:** It will download and compile the dependencies).

## Secrets

Secrets were managed by [`agenix`](https://github.com/ryantm/agenix).
No other solution is used because we don’t have secrets any more.

## Deployements

Currently deployements are done with [`morph`](https://github.com/DBCDK/morph).
