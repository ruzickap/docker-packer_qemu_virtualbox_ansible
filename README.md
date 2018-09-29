# Dockerfile with Packer, QEMU, VirtualBox, Ansible (with winrm and boto3 Python modules)

[![Docker Hub; peru/packer_qemu_virtualbox_ansible](https://img.shields.io/badge/dockerhub-peru%2Fpacker_qemu_virtualbox_ansible-green.svg)](https://registry.hub.docker.com/u/peru/packer_qemu_virtualbox_ansible)[![Size](https://images.microbadger.com/badges/image/peru/packer_qemu_virtualbox_ansible.svg)](https://microbadger.com/images/peru/packer_qemu_virtualbox_ansible)[![Docker pulls](https://img.shields.io/docker/pulls/peru/packer_qemu_virtualbox_ansible.svg)](https://hub.docker.com/r/peru/packer_qemu_virtualbox_ansible/)[![Docker Build](https://img.shields.io/docker/automated/peru/packer_qemu_virtualbox_ansible.svg)](https://hub.docker.com/r/peru/packer_qemu_virtualbox_ansible/)

This repository provides Dockerfile which can be used to build images for Virtual Machines by Packer.

The docker image is primary created for building Packer Templates located in this repository [https://github.com/ruzickap/packer-templates](https://github.com/ruzickap/packer-templates), but it can be used everywhere.

## Installation steps

To use this Docker image you need to install VirtualBox and Docker to your OS (Fedora / Ubuntu). This may work on other operating systems too, but I didn't have a chance to test it.

### Ubuntu installation steps (Docker + Virtualbox)

```bash
sudo apt update
sudo apt install -y --no-install-recommends curl git docker.io virtualbox
sudo gpasswd -a ${USER} docker

sudo reboot
```

### Fedora installation steps (Docker + Virtualbox)

```bash
sudo sed -i 's@^SELINUX=enforcing@SELINUX=disabled@' /etc/selinux/config
sudo dnf upgrade -y
# Reboot if necessary (especialy if you upgrade the kernel or related packages)

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
You can replace `-only=qemu` by `-only=virtualbox-iso` to build virtualbox images.

You can see the console of virtual machine by turning on `-var headless=false`.
(It will connect the "X GUI" from the docker to your X server)

### Common part for all

```bash
PACKER_TEMPLATES_GIT="https://github.com/ruzickap/packer-templates"
PACKER_TEMPLATES_DIR="$PWD/packer-templates"
#ISO_DIR="/var/tmp"
ISO_DIR="/home/pruzicka/data2/iso"

git clone --recurse-submodules $PACKER_TEMPLATES_GIT

test -d $ISO_DIR || mkdir $ISO_DIR
```

### Build CentOS image

```bash
NAME="my_centos-7-x86_64"
CENTOS_VERSION="7"
CENTOS_TYPE="NetInstall"
CENTOS_TAG="1804"

docker run --rm -it --privileged -u $(id -u):$(id -g) \
-e DISPLAY=$DISPLAY \
-e NAME=$NAME \
-e CENTOS_VERSION=$CENTOS_VERSION \
-e CENTOS_TYPE=$CENTOS_TYPE \
-e CENTOS_TAG=$CENTOS_TAG \
-e PACKER_IMAGES_OUTPUT_DIR=/var/tmp/ \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v $PACKER_TEMPLATES_DIR:/home/docker/packer \
-v $ISO_DIR:/home/docker/packer/packer_cache \
peru/packer_qemu_virtualbox_ansible build -var headless=true -only=qemu my_centos-7.json
```

### Build Ubuntu image

```bash
NAME="ubuntu-18.04-server-amd64"
UBUNTU_CODENAME="bionic"

docker run --rm -it --privileged -u $(id -u):$(id -g) \
-e DISPLAY=$DISPLAY \
-e NAME=$NAME \
-e UBUNTU_CODENAME=$UBUNTU_CODENAME \
-e PACKER_IMAGES_OUTPUT_DIR=/var/tmp/ \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v $PACKER_TEMPLATES_DIR:/home/docker/packer \
-v $ISO_DIR:/home/docker/packer/packer_cache \
peru/packer_qemu_virtualbox_ansible build -var headless=true -only=qemu ubuntu-server.json
```

```bash
NAME="ubuntu-16.04-server-amd64"
UBUNTU_CODENAME="xenial"

docker run --rm -it --privileged -u $(id -u):$(id -g) \
-e DISPLAY=$DISPLAY \
-e NAME=$NAME \
-e UBUNTU_CODENAME=$UBUNTU_CODENAME \
-e PACKER_IMAGES_OUTPUT_DIR=/var/tmp/ \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v $PACKER_TEMPLATES_DIR:/home/docker/packer \
-v $ISO_DIR:/home/docker/packer/packer_cache \
peru/packer_qemu_virtualbox_ansible build -var headless=true -only=qemu ubuntu-server.json
```

```bash
NAME=ubuntu-18.04-desktop-amd64
UBUNTU_CODENAME="bionic"

docker run --rm -it --privileged -u $(id -u):$(id -g) \
-e DISPLAY=$DISPLAY \
-e NAME=$NAME \
-e UBUNTU_CODENAME=$UBUNTU_CODENAME \
-e PACKER_IMAGES_OUTPUT_DIR=/var/tmp/ \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v $PACKER_TEMPLATES_DIR:/home/docker/packer \
-v $ISO_DIR:/home/docker/packer/packer_cache \
peru/packer_qemu_virtualbox_ansible build -var headless=true -only=qemu ubuntu-desktop.json
```

### Build Windows image

```bash
NAME="my_windows-10-enterprise-x64-eval"
WINDOWS_VERSION="10"
ISO_CHECKSUM="27e4feb9102f7f2b21ebdb364587902a70842fb550204019d1a14b120918e455"
ISO_URL="https://software-download.microsoft.com/download/pr/17134.1.180410-1804.rs4_release_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"

test -f $ISO_DIR/virtio-win.iso || sudo curl -L https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso --output $ISO_DIR/virtio-win.iso

docker run --rm -it --privileged -u $(id -u):$(id -g) \
-e DISPLAY=$DISPLAY \
-e NAME=$NAME \
-e WINDOWS_VERSION=$WINDOWS_VERSION \
-e VIRTIO_WIN_ISO="packer_cache/virtio-win.iso" \
-e ISO_CHECKSUM=$ISO_CHECKSUM \
-e ISO_URL=$ISO_URL \
-e PACKER_IMAGES_OUTPUT_DIR=/var/tmp/ \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v $PACKER_TEMPLATES_DIR:/home/docker/packer \
-v $ISO_DIR:/home/docker/packer/packer_cache \
peru/packer_qemu_virtualbox_ansible build -var headless=true -only=qemu windows.json
```

```bash
NAME="windows-server-2016-standard-x64-eval"
WINDOWS_VERSION="2016"
ISO_CHECKSUM="1ce702a578a3cb1ac3d14873980838590f06d5b7101c5daaccbac9d73f1fb50f"
ISO_URL="https://software-download.microsoft.com/download/pr/Windows_Server_2016_Datacenter_EVAL_en-us_14393_refresh.ISO"

test -f $ISO_DIR/virtio-win.iso || sudo curl -L https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso --output $ISO_DIR/virtio-win.iso

docker run --rm -it --privileged -u $(id -u):$(id -g) \
-e DISPLAY=$DISPLAY \
-e NAME=$NAME \
-e WINDOWS_VERSION=$WINDOWS_VERSION \
-e VIRTIO_WIN_ISO="./packer_cache/virtio-win.iso" \
-e ISO_CHECKSUM=$ISO_CHECKSUM \
-e ISO_URL=$ISO_URL \
-e PACKER_IMAGES_OUTPUT_DIR=/var/tmp/ \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v $PACKER_TEMPLATES_DIR:/home/docker/packer \
-v $ISO_DIR:/home/docker/packer/packer_cache \
peru/packer_qemu_virtualbox_ansible build -var headless=true -only=qemu windows.json
```

```bash
NAME="windows-server-2012-r2-standard-x64-eval"
WINDOWS_VERSION="2012"
ISO_CHECKSUM="6612b5b1f53e845aacdf96e974bb119a3d9b4dcb5b82e65804ab7e534dc7b4d5"
ISO_URL="http://care.dlservice.microsoft.com/dl/download/6/2/A/62A76ABB-9990-4EFC-A4FE-C7D698DAEB96/9600.17050.WINBLUE_REFRESH.140317-1640_X64FRE_SERVER_EVAL_EN-US-IR3_SSS_X64FREE_EN-US_DV9.ISO"

test -f $ISO_DIR/virtio-win.iso || sudo curl -L https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso --output $ISO_DIR/virtio-win.iso

docker run --rm -it --privileged -u $(id -u):$(id -g) \
-e DISPLAY=$DISPLAY \
-e NAME=$NAME \
-e WINDOWS_VERSION=$WINDOWS_VERSION \
-e VIRTIO_WIN_ISO="./packer_cache/virtio-win.iso" \
-e ISO_CHECKSUM=$ISO_CHECKSUM \
-e ISO_URL=$ISO_URL \
-e PACKER_IMAGES_OUTPUT_DIR=/var/tmp/ \
-v /tmp/.X11-unix:/tmp/.X11-unix \
-v $PACKER_TEMPLATES_DIR:/home/docker/packer \
-v $ISO_DIR:/home/docker/packer/packer_cache \
peru/packer_qemu_virtualbox_ansible build -var headless=true -only=qemu windows.json
```
