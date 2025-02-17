See https://github.com/openshift/enhancements/pull/565

# How to run - automatic makefile
- Set PULL_SECRET environment variable to your pull secret
- `make start-iso` - Spins up a VM with the the liveCD. This will automatically perform the following actions:
	- Extract the openshift installer from the release image
	- Generate the install-config.yaml
	- Execute the openshift-installer `create single-node-ignition-config` command to generate the bootstrap-in-place-for-live-iso.ign.
	- Add the complete-installation.service to bootstrap-in-place-for-live-iso.ign.
	- Download the RHCOS live ISO
	- Embed the bootstrap-in-place Ignition to the ISO.
	- Create a libvirt network & VM
	- Boot the VM with that ISO
- You can now monitor the progress using `make ssh` and `journalctl -f -u bootkube.service` or `kubectl --kubeconfig ./sno-workdir/auth/kubeconfig get clusterversion`

# How to run - manual mode
- Create a workdir for the installer - `mkdir sno-workdir`
- Create an `install-config.yaml` in the sno-workdir. An example file can be found in `./install-config.yaml.template`. There are a small number of fields in the template that should be set by hand. Reasonable defaults are given below.
  * `MACHINE_NETWORK` - the machine network CIDR. A good default is `192.168.126.0/24`. 
  * `CLUSTER_SVC_NETWORK` - the cluster service network CIDR. A good default is `172.30.0.0/16`.
  * `CLUSTER_NETWORK` - the cluster network CIDR. A good default is `10.128.0.0/14`.
- Download the ISO to the workdir `./download_live_iso.sh sno-workdir/base.iso`
- Get an installer binary using `oc adm release extract --command=openshift-install --to ./bin ${RELEASE_IMAGE}
`
- (optional) If custom manifests are defined, generate manifests with `./manifests.sh` and then copy custom manifests into generated folder. Invocation examples:
```bash
INSTALLATION_DISK=/dev/sda \
RELEASE_IMAGE=quay.io/openshift-release-dev/ocp-release:4.8.0-fc.7-x86_64 \
INSTALLER_BIN=./bin/openshift-install \
INSTALLER_WORKDIR=./sno-workdir \
./manifests.sh
```
```bash
cp ./manifests/*.yaml $INSTALLER_WORKDIR/manifests/
```
- Generate an ignition file using the installer with `./generate.sh`. Invocation example:
```bash
INSTALLATION_DISK=/dev/sda \
RELEASE_IMAGE=quay.io/openshift-release-dev/ocp-release:4.8.0-fc.7-x86_64 \
INSTALLER_BIN=./bin/openshift-install \
INSTALLER_WORKDIR=./sno-workdir \
./generate.sh
```
- Embed the ignition file inside the ISO using `./embed.sh`. Invocation example:
```bash
ISO_PATH=./sno-workdir/base.iso \
IGNITION_PATH=./sno-workdir/bootstrap-in-place-for-live-iso.ign \
OUTPUT_PATH=./sno-workdir/embedded.iso \
./embed.sh
```

You can now use `sno-workdir/embedded.iso` to install a single node cluster. The kubeconfig file can be found in `./sno-workdir/auth/kubeconfig`

# Other notes

* Default release image is quay.io/openshift-release-dev/ocp-release:4.8.0-fc.7-x86_64, you can override it using RELEASE_IMAGE env var.
* make will execute the generate.sh script with INSTALLATION_DISK=/dev/vda
* if you’re running the installation on a BM environment, it should be updated.
