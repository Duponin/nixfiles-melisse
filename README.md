# Nixfiles
## Install a VM

* Add network to VM **(!!!ONLY NEEDED IF NO DHCP IS AVAILABLE!!!)**
  * `ip a add 2a0c:e304:c0fe:1::XXXX/64 dev <dev>`
    * Where `XXXX` is an IP
    * Where `dev` is the VM interface (generally `ens3`)
  * `ip r add default via 2a0c:e304:c0fe:1::1 dev <dev>`
    * Where `dev` is the VM interface (generally `ens3`)
  * `echo "nameserver 2a0c:e300::100" > /etc/resolv.conf`
* Launch install script
  * `curl https://git.locahlo.st/chatons/nixfiles/-/raw/master/scripts/install.sh | bash -s <disk> <hostname>`
    * Where `<disk>` is the target disk (generally `/dev/vda`)
    * Where `<hostname>` the target hostname
    * **NOTE:** target **MUST** has a valid `configuration.nix` under `configuration/hosts/<hostname>/` in this repository

The VM should be accessible via SSH after reboot.

## `nix-shell` and dependencies

So tools are needed to perform actions such secrets encryption or deployements.
If you have [`Nix`](https://nixos.org/guides/install-nix.html) installed on your machine you don't need anything else, any dependencies will be installed by entering in the `nix-shell` (**WARNING:** It will download and compile the dependencies).

## Secrets

Currently secrets are managed by [`agenix`](https://github.com/ryantm/agenix).

### Generate a secret

1. Get `age` commands by entering in the `nix-shell`
2. Enter in the `secrets` directory
3. Edit the secret with `age -e <the file holding a secret>.age`
  1. a few random secrets can be generated with `base64 /dev/urandom | head`
4. Save and close your `$EDITOR`

## Deployements

Currently deployements are done with [`morph`](https://github.com/DBCDK/morph).
To perform a deployement, the following tasks can be done:

``` sh
ssh anoat.melisse.org
sudo su - morph
cd ~/src/git.locahlo.st/chatons/nixfiles
git pull
nix-shell
morph build deploy.nix
morph deploy deploy.nix test
```
