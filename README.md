# Dockerfile with Packer, QEMU, VirtualBox, Ansible (with winrm and boto3 Python modus)

This repository provides Dockerfile which can be used to build Virtual Machines by Packer.

The docker image is primary created for building Packer Templates located in this repository https://github.com/ruzickap/packer-templates, but it can be used everywhere.

## Ubuntu example

Real example how to use the Docker image to build Packer images.

```
PACKER_TEMPLATES_GIT="https://github.com/ruzickap/packer-templates"
PACKER_TEMPLATES_DIR="$PWD/packer-templates"
ISO_DIR="/var/tmp"

apt update
apt install -y git docker.io

git clone $PACKER_TEMPLATES_GIT

docker run --rm -it --privileged --cap-add=ALL -v /lib/modules:/lib/modules:ro -v $PACKER_TEMPLATES_DIR:/var/tmp/packer-templates/ -v $ISO_DIR:/var/tmp/packer-templates/packer_cache/ peru/packer_qemu_virtualbox_ansible
```

## Fedora example

```
```
