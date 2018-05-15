[![Docker Hub; peru/packer_qemu_virtualbox_ansible](https://img.shields.io/badge/dockerhub-peru%2Fpacker_qemu_virtualbox_ansible-green.svg)](https://registry.hub.docker.com/u/peru/packer_qemu_virtualbox_ansible)
[![](https://images.microbadger.com/badges/image/peru/packer_qemu_virtualbox_ansible.svg)](https://microbadger.com/images/peru/packer_qemu_virtualbox_ansible)
[![Docker pulls](https://img.shields.io/docker/pulls/peru/packer_qemu_virtualbox_ansible.svg)](https://hub.docker.com/r/peru/packer_qemu_virtualbox_ansible/)
[![Docker Build](https://img.shields.io/docker/automated/peru/packer_qemu_virtualbox_ansible.svg)](https://hub.docker.com/r/peru/packer_qemu_virtualbox_ansible/)

# Dockerfile with Packer, QEMU, VirtualBox, Ansible (with winrm and boto3 Python modules)

This repository provides Dockerfile which can be used to build images for Virtual Machines by Packer.

The docker image is primary created for building Packer Templates located in this repository https://github.com/ruzickap/packer-templates, but it can be used everywhere.

## Ubuntu example

Real example how to use the Docker image to build Packer images in Ubuntu.

```
PACKER_TEMPLATES_GIT="https://github.com/ruzickap/packer-templates"
PACKER_TEMPLATES_DIR="$PWD/packer-templates"
ISO_DIR="/var/tmp"

sudo apt update
sudo apt install -y git docker.io virtualbox
sudo gpasswd -a ${USER} docker

reboot
```

## Fedora example

Real example how to use the Docker image to build Packer images in Ubuntu.

```
PACKER_TEMPLATES_GIT="https://github.com/ruzickap/packer-templates"
PACKER_TEMPLATES_DIR="$PWD/packer-templates"
ISO_DIR="/var/tmp"

sudo sed -i 's@^SELINUX=enforcing@SELINUX=disabled@' /etc/selinux/config
sudo dnf upgrade -y
sudo dnf install -y http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y git docker VirtualBox
sudo groupadd docker && sudo gpasswd -a ${USER} docker
sudo systemctl enable docker

reboot
```

## Build image from Packer templates

### Centos

```
git clone $PACKER_TEMPLATES_GIT

NAME="my_centos-7-x86_64"
CENTOS_VERSION="7"
CENTOS_TYPE="NetInstall"
CENTOS_TAG="1804"
docker run -e NAME=$NAME -e CENTOS_VERSION=$CENTOS_VERSION -e CENTOS_TYPE=$CENTOS_TYPE -e CENTOS_TAG=$CENTOS_TAG --rm -it --privileged --cap-add=ALL -v /lib/modules:/lib/modules:ro -v $PACKER_TEMPLATES_DIR:/var/tmp/packer-templates/ -v $ISO_DIR:/var/tmp/packer-templates/packer_cache/ peru/packer_qemu_virtualbox_ansible build -var headless=true my_centos-7.json
```

### Ubuntu

```
NAME="ubuntu-18.04-server-amd64"
UBUNTU_CODENAME="bionic"

docker run -e NAME=$NAME -e UBUNTU_CODENAME=$UBUNTU_CODENAME --rm -it --privileged --cap-add=ALL -v /lib/modules:/lib/modules:ro -v $PACKER_TEMPLATES_DIR:/var/tmp/packer-templates/ -v $ISO_DIR:/var/tmp/packer-templates/packer_cache/ peru/packer_qemu_virtualbox_ansible build -var headless=true ubuntu-server.json
```

```
NAME="ubuntu-16.04-server-amd64"
UBUNTU_CODENAME="xenial"

docker run -e NAME=$NAME -e UBUNTU_CODENAME=$UBUNTU_CODENAME --rm -it --privileged --cap-add=ALL -v /lib/modules:/lib/modules:ro -v $PACKER_TEMPLATES_DIR:/var/tmp/packer-templates/ -v $ISO_DIR:/var/tmp/packer-templates/packer_cache/ peru/packer_qemu_virtualbox_ansible build -var headless=true ubuntu-server.json
```

### Windows

```
NAME="my_windows-10-enterprise-x64-eval"
WINDOWS_VERSION="10"
VIRTIO_WIN_ISO="$PWD/packer-templates/packer_cache/virtio-win.iso"
ISO_CHECKSUM="27e4feb9102f7f2b21ebdb364587902a70842fb550204019d1a14b120918e455"
ISO_URL="https://software-download.microsoft.com/download/pr/17134.1.180410-1804.rs4_release_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso"

docker run -e NAME=$NAME -e WINDOWS_VERSION=$WINDOWS_VERSION -e VIRTIO_WIN_ISO=$VIRTIO_WIN_ISO -e ISO_CHECKSUM=$ISO_CHECKSUM -e ISO_URL=$ISO_URL --rm -it --privileged --cap-add=ALL -v /lib/modules:/lib/modules:ro -v $PACKER_TEMPLATES_DIR:/var/tmp/packer-templates/ -v $ISO_DIR:/var/tmp/packer-templates/packer_cache/ peru/packer_qemu_virtualbox_ansible build -var headless=true windows.json
```

```
NAME="windows-server-2016-standard-x64-eval"
WINDOWS_VERSION="2016"
VIRTIO_WIN_ISO="$PWD/packer-templates/packer_cache/virtio-win.iso"
ISO_CHECKSUM="1ce702a578a3cb1ac3d14873980838590f06d5b7101c5daaccbac9d73f1fb50f" ISO_URL="http://care.dlservice.microsoft.com/dl/download/1/4/9/149D5452-9B29-4274-B6B3-5361DBDA30BC/14393.0.161119-1705.RS1_REFRESH_SERVER_EVAL_X64FRE_EN-US.ISO"

docker run -e NAME=$NAME -e WINDOWS_VERSION=$WINDOWS_VERSION -e VIRTIO_WIN_ISO=$VIRTIO_WIN_ISO -e ISO_CHECKSUM=$ISO_CHECKSUM -e ISO_URL=$ISO_URL --rm -it --privileged --cap-add=ALL -v /lib/modules:/lib/modules:ro -v $PACKER_TEMPLATES_DIR:/var/tmp/packer-templates/ -v $ISO_DIR:/var/tmp/packer-templates/packer_cache/ peru/packer_qemu_virtualbox_ansible build -var headless=true windows.json
```
