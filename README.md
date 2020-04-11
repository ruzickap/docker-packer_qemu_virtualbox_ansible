# Dockerfile with Packer, QEMU, VirtualBox, Ansible (with winrm Python module)

[![Docker Hub; peru/packer_qemu_virtualbox_ansible](https://img.shields.io/badge/dockerhub-peru%2Fpacker_qemu_virtualbox_ansible-green.svg)](https://registry.hub.docker.com/u/peru/packer_qemu_virtualbox_ansible)
[![Size](https://images.microbadger.com/badges/image/peru/packer_qemu_virtualbox_ansible.svg)](https://microbadger.com/images/peru/packer_qemu_virtualbox_ansible)
[![Docker pulls](https://img.shields.io/docker/pulls/peru/packer_qemu_virtualbox_ansible.svg)](https://hub.docker.com/r/peru/packer_qemu_virtualbox_ansible/)
[![Docker Build](https://img.shields.io/docker/automated/peru/packer_qemu_virtualbox_ansible.svg)](https://hub.docker.com/r/peru/packer_qemu_virtualbox_ansible/)

This repository provides Dockerfile which can be used to build images
for Virtual Machines by Packer.

The docker image is primary created for building Packer Templates located
in this repository [https://github.com/ruzickap/packer-templates](https://github.com/ruzickap/packer-templates),
but it can be used everywhere.

## Installation steps

To use this Docker image you need to install VirtualBox and Docker to your OS
(Fedora / Ubuntu). This may work on other operating systems too, but I didn't
have a chance to test it.

### Ubuntu installation steps (Docker + VirtualBox)

```bash
sudo apt update
sudo apt install -y --no-install-recommends curl git docker.io virtualbox
sudo gpasswd -a ${USER} docker
# This is mandatory for Ubuntu otherwise docker container will not have access to /dev/kvm - this is default in Fedora (https://bugzilla.redhat.com/show_bug.cgi?id=993491)
sudo bash -c "echo 'KERNEL==\"kvm\", GROUP=\"kvm\", MODE=\"0666\"' > /etc/udev/rules.d/60-qemu-system-common.rules"
sudo reboot
```

### Fedora installation steps (Docker + VirtualBox)

```bash
sudo sed -i 's@^SELINUX=enforcing@SELINUX=disabled@' /etc/selinux/config
sudo dnf upgrade -y
# Reboot if necessary (especially if you upgrade the kernel or related packages)

sudo dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y akmod-VirtualBox curl docker git kernel-devel-$(uname -r) libvirt-daemon-kvm
sudo akmods

sudo bash -c 'echo "vboxdrv" > /etc/modules-load.d/vboxdrv.conf'
sudo usermod -a -G libvirt ${USER}
sudo groupadd docker && sudo gpasswd -a ${USER} docker
sudo systemctl enable docker

sudo reboot
```

## Build image from Packer templates

Real example how to use the Docker image to build Packer images for libvirt/qemu.
You can replace `-only=qemu` by `-only=virtualbox-iso` to build VirtualBox images.

You can see the console of virtual machine by turning on `-var headless=false`.
(It will connect the "X GUI" from the docker to your X server)

### Common mandatory part for all

```bash
PACKER_TEMPLATES_GIT="https://github.com/ruzickap/packer-templates"
PACKER_TEMPLATES_DIR="$PWD/packer-templates"
PACKER_IMAGES_OUTPUT_DIR="/var/tmp/packer-templates-images"

git clone --recurse-submodules $PACKER_TEMPLATES_GIT
cd packer-templates
TMPDIR="$PWD/packer_cache"

test -d $TMPDIR || mkdir -v $TMPDIR
test -d $PACKER_IMAGES_OUTPUT_DIR || mkdir -v $PACKER_IMAGES_OUTPUT_DIR
```

### Build CentOS image

```bash
export NAME="my_centos-7-x86_64"
export CENTOS_VERSION="7"
export CENTOS_TYPE="NetInstall"
export CENTOS_TAG="1804"
export PACKER_RUN_TIMEOUT="7200"  # keep build running for max 2 hours

docker run --rm -it -u $(id -u):$(id -g) --privileged --name "packer_${NAME}" \
-v $PACKER_IMAGES_OUTPUT_DIR:/home/docker/packer_images_output_dir \
-v $PWD:/home/docker/packer \
-v $TMPDIR:/home/docker/packer/packer_cache \
-e PACKER_RUN_TIMEOUT \
-e NAME -e CENTOS_VERSION -e CENTOS_TYPE -e CENTOS_TAG \
-e PACKER_IMAGES_OUTPUT_DIR=/home/docker/packer_images_output_dir \
peru/packer_qemu_virtualbox_ansible build -only=qemu -var headless=true my_centos-7.json
```

### Build Ubuntu images

#### Ubuntu Server

```bash
export NAME="ubuntu-18.04-server-amd64"
export UBUNTU_TYPE="server"
export UBUNTU_VERSION="18.04"
export UBUNTU_IMAGES_URL="http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/installer-amd64/current/images/"

docker run --rm -it -u $(id -u):$(id -g) --privileged --name "packer_${NAME}" \
-v $PACKER_IMAGES_OUTPUT_DIR:/home/docker/packer_images_output_dir \
-v $PWD:/home/docker/packer \
-v $TMPDIR:/home/docker/packer/packer_cache \
-e NAME -e UBUNTU_TYPE -e UBUNTU_VERSION -e UBUNTU_IMAGES_URL \
-e PACKER_IMAGES_OUTPUT_DIR=/home/docker/packer_images_output_dir \
peru/packer_qemu_virtualbox_ansible build -only=qemu -var headless=true ubuntu-server.json
```

```bash
export NAME="ubuntu-16.04-server-amd64"
export UBUNTU_TYPE="server"
export UBUNTU_VERSION="16.04"
export UBUNTU_IMAGES_URL="http://archive.ubuntu.com/ubuntu/dists/xenial-updates/main/installer-amd64/current/images/"

docker run --rm -it -u $(id -u):$(id -g) --privileged --name "packer_${NAME}" \
-v $PACKER_IMAGES_OUTPUT_DIR:/home/docker/packer_images_output_dir \
-v $PWD:/home/docker/packer \
-v $TMPDIR:/home/docker/packer/packer_cache \
-e NAME -e UBUNTU_TYPE -e UBUNTU_VERSION -e UBUNTU_IMAGES_URL \
-e PACKER_IMAGES_OUTPUT_DIR=/home/docker/packer_images_output_dir \
peru/packer_qemu_virtualbox_ansible build -only=qemu -var headless=true ubuntu-server.json
```

#### Ubuntu Desktop

```bash
export NAME="ubuntu-18.04-desktop-amd64"
export UBUNTU_TYPE="desktop"
export UBUNTU_VERSION="18.04"
export UBUNTU_IMAGES_URL="http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/installer-amd64/current/images/"

docker run --rm -it -u $(id -u):$(id -g) --privileged --name "packer_${NAME}" \
-v $PACKER_IMAGES_OUTPUT_DIR:/home/docker/packer_images_output_dir \
-v $PWD:/home/docker/packer \
-v $TMPDIR:/home/docker/packer/packer_cache \
-e NAME -e UBUNTU_TYPE -e UBUNTU_VERSION -e UBUNTU_IMAGES_URL \
-e PACKER_IMAGES_OUTPUT_DIR=/home/docker/packer_images_output_dir \
peru/packer_qemu_virtualbox_ansible build -only=qemu -var headless=true ubuntu-desktop.json
```

### Build Windows image

#### Common mandatory part for all Windows images

Download the VirtIO driver image file:

```bash
export VIRTIO_WIN_ISO="packer_cache/virtio-win.iso"
wget -c https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso -O $VIRTIO_WIN_ISO
```

#### Windows 10

```bash
export NAME="my_windows-10-enterprise-x64-eval"
export WINDOWS_VERSION="10"
export ISO_URL="https://software-download.microsoft.com/download/pr/17763.1.180914-1434.rs5_release_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"

docker run --rm -it -u $(id -u):$(id -g) --privileged --name "packer_${NAME}" \
-v $PACKER_IMAGES_OUTPUT_DIR:/home/docker/packer_images_output_dir \
-v $PWD:/home/docker/packer \
-v $TMPDIR:/home/docker/packer/packer_cache \
-e NAME -e WINDOWS_VERSION -e ISO_URL -e VIRTIO_WIN_ISO \
-e PACKER_IMAGES_OUTPUT_DIR=/home/docker/packer_images_output_dir \
peru/packer_qemu_virtualbox_ansible build -only=qemu -var headless=true windows.json
```

#### Windows Server 2019

```bash
export NAME="windows-server-2019-standard-x64-eval"
export WINDOWS_VERSION="2019"
export ISO_URL="https://software-download.microsoft.com/download/pr/17763.1.180914-1434.rs5_release_SERVER_EVAL_x64FRE_en-us.iso"

docker run --rm -it -u $(id -u):$(id -g) --privileged --name "packer_${NAME}" \
-v $PACKER_IMAGES_OUTPUT_DIR:/home/docker/packer_images_output_dir \
-v $PWD:/home/docker/packer \
-v $TMPDIR:/home/docker/packer/packer_cache \
-e NAME -e WINDOWS_VERSION -e ISO_URL -e VIRTIO_WIN_ISO \
-e PACKER_IMAGES_OUTPUT_DIR=/home/docker/packer_images_output_dir \
peru/packer_qemu_virtualbox_ansible build -only=qemu -var headless=true windows.json
```

#### Windows Server 2016

```bash
export NAME="windows-server-2016-standard-x64-eval"
export WINDOWS_VERSION="2016"
export ISO_URL="https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"

docker run --rm -it -u $(id -u):$(id -g) --privileged --name "packer_${NAME}" \
-v $PACKER_IMAGES_OUTPUT_DIR:/home/docker/packer_images_output_dir \
-v $PWD:/home/docker/packer \
-v $TMPDIR:/home/docker/packer/packer_cache \
-e NAME -e WINDOWS_VERSION -e ISO_URL -e VIRTIO_WIN_ISO \
-e PACKER_IMAGES_OUTPUT_DIR=/home/docker/packer_images_output_dir \
peru/packer_qemu_virtualbox_ansible build -only=qemu -var headless=true windows.json
```

#### Windows Server 2012

```bash
export NAME="windows-server-2012-r2-standard-x64-eval"
export WINDOWS_VERSION="2012"
export ISO_URL="http://care.dlservice.microsoft.com/dl/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO"

docker run --rm -it -u $(id -u):$(id -g) --privileged --name "packer_${NAME}" \
-v $PACKER_IMAGES_OUTPUT_DIR:/home/docker/packer_images_output_dir \
-v $PWD:/home/docker/packer \
-v $TMPDIR:/home/docker/packer/packer_cache \
-e NAME -e WINDOWS_VERSION -e ISO_URL -e VIRTIO_WIN_ISO \
-e PACKER_IMAGES_OUTPUT_DIR=/home/docker/packer_images_output_dir \
peru/packer_qemu_virtualbox_ansible build -only=qemu -var headless=true windows.json
```
